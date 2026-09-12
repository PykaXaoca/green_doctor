# Обучение модели идентификации растений

Этот каталог содержит Python-скрипты для обучения модели распознавания
растений и конвертации её в TFLite для использования в мобильном приложении.

## Требования

- Python 3.10 или выше
- TensorFlow 2.15+
- 8+ ГБ ОЗУ (для обучения)

## Установка

```bash
cd ml
python -m venv venv
venv\Scripts\activate     # Windows
# source venv/bin/activate  # Linux / macOS
pip install -r requirements.txt
