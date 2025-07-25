# Автоматическая суммаризация новостных статей для русского языка

### Задание
В данной работе была разработана модель для автоматической генерации заголовков русскоязычных новостных статей на основе архитектуры трансформеров. Были рассмотрены различные подходы к суммаризации текста, проведён анализ [данных](https://huggingface.co/datasets/IlyaGusev/gazeta) и обучена модель [ruT5-base](https://huggingface.co/ai-forever/ruT5-base). Качество полученных заголовков было оценено с использованием метрик ROUGE, BLEU и BERTScore.

Основные достижения включают успешное применение современной модели для задачи суммаризации и оценку её эффективности с использованием различных метрик. Разработанная модель демонстрирует высокую точность и релевантность сгенерированных заголовков. Тем не менее, существуют области для улучшения, включая работу с некорректными заголовками и более глубокое понимание контекста.
Ограничения включают необходимость дальнейшего улучшения модели и использование большего объёма данных для обучения.

### Решение
[Файл с кодом и пояснениями](/Projects/09_Graduate_work/dplm.ipynb)
