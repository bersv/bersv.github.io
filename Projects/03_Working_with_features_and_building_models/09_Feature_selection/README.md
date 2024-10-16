# Feature Selection

### Задание
Необходимо решить задачу классификации точек наиболее эффективно. Для этого в работе применить различные методы по отбору признаков. Отбор признаков предпочтительнее осуществлять основываясь на математическом аппарате, поэтому данные для этого задания будут сгенерированы, чтобы избежать признаков с физическим смыслом.

### Этапы работы
1. Сгенерируйте данные с помощью кода:  
   ```python
   from sklearn.datasets import make_classification
   x_data_generated, y_data_generated = make_classification(scale=1)
   ```
2. Постройте модель логистической регрессии и оцените среднюю точность. Для этого используйте следующий код:
   ```python
   cross_val_score(LogisticRegression(), x, y, scoring='accuracy').mean()
   ```
3. Используйте статистические методы для отбора признаков:
   - Выберите признаки на основе матрицы корреляции.
   - Отсеките низковариативные признаки (VarianceThreshold).
   - Повторите п. 2 на отобранных признаках в п. 3a, п. 3b.
4. Осуществите отбор признаков на основе дисперсионного анализа:
   - Выберите 5 лучших признаков с помощью скоринговой функции для классификации f_classif.
   - Повторите п. 2 на отобранных признаках.
5. Отбор с использованием моделей:
   - Реализуйте отбор признаков с помощью логистической регрессии. Отобранные признаки подайте далее на вход в саму логистическую регрессию (SelectFromModel). Используйте L1 регуляризацию.
   - Реализуйте отбор признаков с помощью модели RandomForest и встроенного атрибута feature_impotance.
   - Повторите п. 2 на отобранных признаках в п. 5a, п. 5b.
6. Перебор признаков:
   - SequentialFeatureSelector.
   - Повторите п. 2 на отобранных признаках.
7. Сформулируйте выводы по проделанной работе.
   - Сделайте таблицу вида |способ выбора признаков|количество признаков|средняя точность модели|.

### Решение
[Файл с кодом и пояснениями](/Projects/03_Working_with_features_and_building_models/09_Feature_selection/Solution.ipynb)
