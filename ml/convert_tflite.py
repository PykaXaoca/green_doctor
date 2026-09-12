"""
Конвертация SavedModel в TFLite с int8-квантованием.

Использование:
    python convert_tflite.py
"""

import argparse
import json
from pathlib import Path

import numpy as np
import tensorflow as tf


def parse_args():
    parser = argparse.ArgumentParser(description='Конвертация модели в TFLite')
    parser.add_argument('--input', type=str, default='./output/saved_model')
    parser.add_argument('--output', type=str,
                        default='../assets/models/plant_identification_model.tflite')
    parser.add_argument('--labels-output', type=str,
                        default='../assets/models/labels.txt')
    parser.add_argument('--quantize', type=str, default='int8',
                        choices=['none', 'dynamic', 'int8'],
                        help='Режим квантования')
    return parser.parse_args()


def representative_dataset(data_dir, img_size=224, num_samples=100):
    """Генератор примеров для int8-квантования."""
    from tensorflow.keras.preprocessing import image
    from pathlib import Path

    files = list(Path(data_dir).rglob('*.jpg'))[:num_samples]
    if not files:
        files = list(Path(data_dir).rglob('*.png'))[:num_samples]

    for f in files:
        img = image.load_img(f, target_size=(img_size, img_size))
        arr = image.img_to_array(img)
        arr = (arr / 127.5) - 1.0
        yield [np.expand_dims(arr, axis=0).astype(np.float32)]


def main():
    args = parse_args()

    input_dir = Path(args.input)
    output_path = Path(args.output)
    labels_path = Path(args.labels_output)

    if not input_dir.exists():
        print(f'[ERROR] SavedModel не найден: {input_dir}')
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)

    print(f'[INFO] Загрузка модели: {input_dir}')
    model = tf.saved_model.load(str(input_dir))

    # Создаём конкретную функцию для конвертации.
    concrete_func = model.signatures['serving_default']

    converter = tf.lite.TFLiteConverter.from_concrete_functions(
        [concrete_func]
    )

    if args.quantize == 'dynamic':
        print('[INFO] Применяем dynamic range quantization...')
        converter.optimizations = [tf.lite.Optimize.DEFAULT]

    elif args.quantize == 'int8':
        print('[INFO] Применяем int8 quantization (full integer)...')
        converter.optimizations = [tf.lite.Optimize.DEFAULT]

        # Ищем датасет для калибровки.
        dataset_dir = Path('./dataset')
        if dataset_dir.exists():
            converter.representative_dataset = lambda: representative_dataset(
                str(dataset_dir)
            )
            converter.target_spec.supported_ops = [
                tf.lite.OpsSet.TFLITE_BUILTINS_INT8,
            ]
            converter.inference_input_type = tf.uint8
            converter.inference_output_type = tf.uint8
        else:
            print('[WARN] Датасет не найден — int8-квантование без калибровки')
            converter.optimizations = [tf.lite.Optimize.DEFAULT]

    print('[INFO] Конвертация...')
    tflite_model = converter.convert()

    with open(output_path, 'wb') as f:
        f.write(tflite_model)

    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f'[DONE] Модель сохранена: {output_path}')
    print(f'[INFO] Размер: {size_mb:.2f} МБ')

    # Проверяем метки.
    if not labels_path.exists():
        print(f'[WARN] Файл меток не найден: {labels_path}')
        print('Проверьте labels.txt в output-папке обучения.')
    else:
        with open(labels_path, encoding='utf-8') as f:
            labels = [line.strip() for line in f if line.strip()]
        print(f'[INFO] Классов: {len(labels)}')

    # Проверяем модель.
    print('\n[INFO] Проверка модели...')
    interpreter = tf.lite.Interpreter(model_path=str(output_path))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print(
        f'[INFO] Вход: {input_details[0]["shape"]} ({input_details[0]["dtype"]})')
    print(
        f'[INFO] Выход: {output_details[0]["shape"]} ({output_details[0]["dtype"]})')

    # Тестовый inference.
    input_shape = input_details[0]['shape']
    test_input = np.random.rand(*input_shape).astype(
        input_details[0]['dtype']
    )
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    print(f'[INFO] Тестовый вывод: shape={output.shape}, '
          f'max={output.max():.4f}')


if __name__ == '__main__':
    main()
