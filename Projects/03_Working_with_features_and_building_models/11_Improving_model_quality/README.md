# Улучшение качества модели

### Задание
Необходимо решить задачу классификации наличия болезни сердца у пациентов наиболее эффективно. Данные для обучения моделей необходимо загрузить самостоятельно с [сайта](https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction). Целевая переменная – наличие болезни сердца (HeartDisease). Она принимает значения 0 или 1 в зависимости от отсутствия или наличия болезни соответственно.

### Этапы работы
1. Получите данные и загрузите их в рабочую среду.
2. Подготовьте датасет к обучению моделей. Категориальные переменные переведите в цифровые значения. Можно использовать pd.get_dummies, preprocessing.LabelEncoder. Старайтесь не использовать для этой задачи циклы.
3. Разделите выборку на обучающее и тестовое подмножество. 80% данных оставить на обучающее множество, 20% на тестовое.
4. Обучите модель логистической регрессии с параметрами по умолчанию.
5. Подсчитайте основные метрики модели. Используйте следующие метрики и функцию:
   ```python
   cross_validate(…, cv=10, scoring=['accuracy','recall','precision', 'f1'])
   ```
6. Оптимизируйте 3-4 параметра модели:
   - Используйте GridSearchCV.
   - Используйте RandomizedSearchCV.
   - Добавьте в п. 6b 2-5 моделей классификации и вариации их параметров.
   - Повторите п. 5 после каждого итогового изменения параметров.
7. Сформулируйте выводы по проделанной работе. Сравните метрики построенных моделей.

### Решение
[Файл с кодом и пояснениями](/Projects/03_Working_with_features_and_building_models/11_Improving_model_quality/Solution.ipynb)
