
---

## Файл 3. `ml/train_model.py` (новый)

```python
"""
Обучение модели классификации растений.

Использование:
    python train_model.py --data ./dataset --epochs 30 --batch-size 32
"""

import argparse
import json
import os
import sys
from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.applications import MobileNetV3Small


def parse_args():
    parser = argparse.ArgumentParser(description='Обучение модели распознавания растений')
    parser.add_argument('--data', type=str, default='./dataset',
                        help='Путь к папке с датасетом (подпапки = классы)')
    parser.add_argument('--output', type=str, default='./output',
                        help='Путь для сохранения результатов')
    parser.add_argument('--epochs', type=int, default=30)
    parser.add_argument('--batch-size', type=int, default=32)
    parser.add_argument('--img-size', type=int, default=224)
    parser.add_argument('--lr', type=float, default=0.001)
    parser.add_argument('--val-split', type=float, default=0.2)
    parser.add_argument('--seed', type=int, default=42)
    return parser.parse_args()


def build_dataset(data_dir, img_size, batch_size, val_split, seed):
    """Загружает датасет из папки и делит на train/val."""
    train_ds = keras.utils.image_dataset_from_directory(
        data_dir,
        validation_split=val_split,
        subset='training',
        seed=seed,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        label_mode='categorical',
    )
    val_ds = keras.utils.image_dataset_from_directory(
        data_dir,
        validation_split=val_split,
        subset='validation',
        seed=seed,
        image_size=(img_size, img_size),
        batch_size=batch_size,
        label_mode='categorical',
    )
    return train_ds, val_ds


def build_model(num_classes, img_size):
    """MobileNetV3-Small с предобученными весами ImageNet."""
    base = MobileNetV3Small(
        input_shape=(img_size, img_size, 3),
        include_top=False,
        weights='imagenet',
        include_preprocessing=True,
    )
    base.trainable = False  # сначала обучаем только верхушку

    inputs = keras.Input(shape=(img_size, img_size, 3))
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(256, activation='relu')(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)

    model = keras.Model(inputs, outputs)
    return model, base


def main():
    args = parse_args()

    data_dir = Path(args.data)
    if not data_dir.exists():
        print(f'[ERROR] Папка с датасетом не найдена: {data_dir}')
        sys.exit(1)

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    print('[INFO] Загрузка датасета...')
    train_ds, val_ds = build_dataset(
        str(data_dir), args.img_size, args.batch_size, args.val_split, args.seed,
    )

    class_names = sorted([p.name for p in data_dir.iterdir() if p.is_dir()])
    num_classes = len(class_names)
    print(f'[INFO] Найдено классов: {num_classes}')
    print(f'[INFO] Классы: {class_names}')

    # Сохраняем метки сразу — пригодятся для TFLite.
    labels_path = output_dir / 'labels.txt'
    with open(labels_path, 'w', encoding='utf-8') as f:
        for name in class_names:
            f.write(f'{name}\n')
    print(f'[INFO] Метки сохранены: {labels_path}')

    # Нормализация и кеширование.
    normalization = layers.Rescaling(1.0 / 127.5, offset=-1)

    train_ds = train_ds.map(lambda x, y: (normalization(x), y)).cache().prefetch(
        tf.data.AUTOTUNE
    )
    val_ds = val_ds.map(lambda x, y: (normalization(x), y)).cache().prefetch(
        tf.data.AUTOTUNE
    )

    # Модель.
    model, base = build_model(num_classes, args.img_size)
    model.compile(
        optimizer=keras.optimizers.Adam(args.lr),
        loss='categorical_crossentropy',
        metrics=['accuracy'],
    )

    # Callbacks.
    callbacks = [
        keras.callbacks.ModelCheckpoint(
            filepath=str(output_dir / 'best_model.keras'),
            save_best_only=True,
            monitor='val_accuracy',
            mode='max',
        ),
        keras.callbacks.EarlyStopping(
            patience=5,
            monitor='val_accuracy',
            mode='max',
            restore_best_weights=True,
        ),
        keras.callbacks.ReduceLROnPlateau(
            factor=0.5, patience=3, min_lr=1e-6,
        ),
    ]

    # Этап 1: обучение верхушки.
    print('\n[INFO] Этап 1: обучение классификатора (база заморожена)...')
    history1 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        callbacks=callbacks,
    )

    # Этап 2: fine-tuning последних слоёв.
    print('\n[INFO] Этап 2: fine-tuning последних слоёв...')
    base.trainable = True
    # Размораживаем только последние 30 слоёв.
    for layer in base.layers[:-30]:
        layer.trainable = False

    model.compile(
        optimizer=keras.optimizers.Adam(args.lr / 10),
        loss='categorical_crossentropy',
        metrics=['accuracy'],
    )

    history2 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=max(5, args.epochs // 2),
        callbacks=callbacks,
    )

    # Финальная оценка.
    print('\n[INFO] Финальная оценка...')
    loss, acc = model.evaluate(val_ds)
    print(f'[RESULT] Точность на валидации: {acc * 100:.2f}%')

    # Сохраняем в формате SavedModel.
    saved_model_dir = output_dir / 'saved_model'
    model.save(saved_model_dir)
    print(f'[INFO] SavedModel сохранён: {saved_model_dir}')

    # Сохраняем метрики.
    metrics = {
        'final_accuracy': float(acc),
        'final_loss': float(loss),
        'num_classes': num_classes,
        'class_names': class_names,
    }
    with open(output_dir / 'metrics.json', 'w', encoding='utf-8') as f:
        json.dump(metrics, f, indent=2, ensure_ascii=False)

    print('\n[DONE] Обучение завершено.')
    print('Следующий шаг: python convert_tflite.py')


if __name__ == '__main__':
    main()