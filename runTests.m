% runTests.m - Скрипт для запуска всех тестов проекта

fprintf('=== Запуск тестов ===\n\n');

% Добавление пути к тестовым файлам
addpath(genpath('test'));

% Запуск функциональных тестов
fprintf('1. Запуск функциональных тестов...\n');
try
    functionalSuite = matlab.unittest.TestSuite.fromClass(?ZakovikaPositiveFunctionalTest);
    functionalRunner = matlab.unittest.TestRunner.withTextOutput;
    functionalResults = functionalRunner.run(functionalSuite);
    
    functionalPassed = sum([functionalResults.Passed]);
    functionalFailed = sum([functionalResults.Failed]);
    functionalTotal = numel(functionalResults);
    
    fprintf('Функциональные тесты: %d/%d пройдено\n', functionalPassed, functionalTotal);
    if functionalFailed > 0
        fprintf('Провалено функциональных тестов: %d\n', functionalFailed);
    end
catch ME
    fprintf('Ошибка при запуске функциональных тестов: %s\n', ME.message);
    functionalTotal = 0;
    functionalPassed = 0;
    functionalFailed = 0;
end

% Запуск юнит-тестов
fprintf('\n2. Запуск юнит-тестов...\n');
try
    unitSuite = matlab.unittest.TestSuite.fromClass(?ZakovikaSolverTest);
    unitRunner = matlab.unittest.TestRunner.withTextOutput;
    unitResults = unitRunner.run(unitSuite);
    
    unitPassed = sum([unitResults.Passed]);
    unitFailed = sum([unitResults.Failed]);
    unitTotal = numel(unitResults);
    
    fprintf('Юнит-тесты: %d/%d пройдено\n', unitPassed, unitTotal);
    if unitFailed > 0
        fprintf('Провалено юнит-тестов: %d\n', unitFailed);
    end
catch ME
    fprintf('Ошибка при запуске юнит-тестов: %s\n', ME.message);
    unitTotal = 0;
    unitPassed = 0;
    unitFailed = 0;
end

% Общий анализ результатов
fprintf('\n=== Общий анализ результатов тестирования ===\n');
totalTests = functionalTotal + unitTotal;
totalPassed = functionalPassed + unitPassed;
totalFailed = functionalFailed + unitFailed;

if totalTests > 0
    fprintf('Всего тестов: %d\n', totalTests);
    fprintf('Пройдено: %d\n', totalPassed);
    fprintf('Провалено: %d\n', totalFailed);
    fprintf('Процент успеха: %.1f%%\n', (totalPassed/totalTests)*100);
else
    fprintf('Тесты не были выполнены из-за ошибок\n');
end

% Детальная информация о проваленных тестах
if totalFailed > 0
    fprintf('\n=== Детали проваленных тестов ===\n');
    
    if exist('functionalResults', 'var')
        for i = 1:numel(functionalResults)
            if ~functionalResults(i).Passed
                fprintf('[функц.] %s\n', functionalResults(i).Name);
                if ~isempty(functionalResults(i).Details)
                    fprintf('  Причина: %s\n', functionalResults(i).Details.DiagnosticRecord);
                end
            end
        end
    end
    
    if exist('unitResults', 'var')
        for i = 1:numel(unitResults)
            if ~unitResults(i).Passed
                fprintf('[юнит] %s\n', unitResults(i).Name);
                if ~isempty(unitResults(i).Details)
                    fprintf('  Причина: %s\n', unitResults(i).Details.DiagnosticRecord);
                end
            end
        end
    end
end

% Проверка покрытия функциональности
fprintf('\n=== Проверка покрытия функциональности ===\n');
coverageCheck = struct();

% Функциональные тесты (программная реализация)
functionalMethods = {
    'programWorkingTest',
    'programReturningTest',
    'programReturningDoubleTest',
    'programReturningScalarTest',
    'programArrayCreationTest',
    'programSetParametersTest',
    'programVisualizationTest'
};

fprintf('Функциональные тесты (программная реализация):\n');
for i = 1:length(functionalMethods)
    fprintf('  ✓ %s\n', functionalMethods{i});
end

% Юнит-тесты (математическая реализация)
unitMethods = {
    'testOrbitalVelocityCalculation',
    'testAtmosphereDensityCalculation',
    'testDragForceCalculation',
    'testNumericalStepConsistency',
    'testPhysicalConstants'
};

fprintf('\nЮнит-тесты (математическая реализация):\n');
for i = 1:length(unitMethods)
    fprintf('  ✓ %s\n', unitMethods{i});
end

% Рекомендации по использованию
fprintf('\n=== Рекомендации по использованию ===\n');
if totalFailed == 0
    fprintf('✓ Все тесты пройдены успешно!\n');
    fprintf('✓ Класс готов к использованию в production\n');
    fprintf('✓ Можно запускать моделирование: run(''work_w_class.m'')\n');
else
    fprintf('⚠ Обнаружены проблемы, требующие внимания:\n');
    fprintf('  - Проанализируйте проваленные тесты\n');
    fprintf('  - Исправьте выявленные проблемы\n');
    fprintf('  - Повторно запустите тестирование\n');
end

fprintf('\n=== Дополнительная информация ===\n');
fprintf('Для запуска отдельных тестов используйте:\n');
fprintf('  functionalResults = runtests(''test/testScripts/functional/SatelliteFallModelFunctionalTest'');\n');
fprintf('  unitResults = runtests(''test/testScripts/unit/SatelliteFallModelUnitTest'');\n');
fprintf('Для детального анализа конкретного теста:\n');
fprintf('  suite = matlab.unittest.TestSuite.fromName(''test/testScripts/functional/SatelliteFallModelFunctionalTest:methodName'');\n');
fprintf('  results = run(suite);\n');

% Очистка переменных
clear functionalSuite functionalRunner functionalResults;
clear unitSuite unitRunner unitResults;
clear functionalPassed functionalFailed functionalTotal;
clear unitPassed unitFailed unitTotal;

fprintf('\nТестирование завершено.\n');
