classdef (TestTags = {'functionaltest'}) ...
 ZakovikaPositiveFunctionalTest < matlab.unittest.TestCase

    methods (TestClassTeardown)
         function teardown(~)
         clearvars;
         end
     end
    
     methods
        function programWorkingTest(testCase)
            % Тест 1: Программа выполняется до конца без исключений
            
            expectedExceptionIdentifier = '';
            actualException.identifier = '';
            
            try
                z = ZakovikaClass(300E3,0,0);
                z.iterate(0.1, 1.0);
            catch actualException
            end
            
            testCase.verifyEqual(expectedExceptionIdentifier, actualException.identifier, ...
                'Программа должна выполняться до конца без исключений');
        end
        
        function programReturningTest(testCase)
            % Тест 2: Программа возвращает непустое значение
            
            z = ZakovikaClass(300E3,0,0);
            actualResult = z.iterate(0.1, 1.0);
            testCase.verifyTrue(~isempty(actualResult), ...
                'Программа должна возвращать непустое значение');
        end
        
        function programReturningDoubleTest(testCase)
            % Тест 3: Программа возвращает значение типа double
            
            z = ZakovikaClass(300E3,0,0);
            actualResult = z.iterate(0.1, 1.0);
            testCase.verifyClass(actualResult, 'double', ...
                'Программа должна возвращать значение типа double');
        end
        
        function programReturningScalarTest(testCase)
            % Тест 4: Программа возвращает скалярное значение
            
            z = ZakovikaClass(300E3,0,0);
            actualResult = z.iterate(0.1, 1.0);
            testCase.verifySize(actualResult, [1, 1], ...
                'Программа должна возвращать скалярное значение');
        end
        
        function programArrayCreationTest(testCase)
            % Тест 5: Программа создает массив данных при выполнении

            z = ZakovikaClass(300E3,0,0);
            % Проверяем начальное состояние
            testCase.verifyLength(z.radiusArray, 0, ...
                'Массив должен быть пустой');
            testCase.verifyLength(z.fiArray, 0, ...
                'Массив должен быть пустой');
            
            % Выполняем итерацию
            z.iterate(0.1, 0.5);
            
            % Проверяем, что история расширилась
            testCase.verifyGreaterThan(length(z.radiusArray), 1, ...
                'Массив должен увеличиваться после выполнения итерации');
            testCase.verifyGreaterThan(length(z.fiArray), 1, ...
                'Массив должен увеличиваться после выполнения итерации');
            
            % Проверяем, что все массивы имеют одинаковую длину
            historyLengths = [...
                length(z.velocityArray), ...
                length(z.radiusArray), ...
                length(z.fiArray);];
            
            testCase.verifyTrue(all(historyLengths == historyLengths(1)), ...
                'Массивы должны иметь одинаковую длину');
        end
        
        function programSetParametersTest(testCase)
            % Тест 6: Программа позволяет установить параметры спутника
            z = ZakovikaClass(300E3,0,0);
            windage = z.moreParams(2.2, 2.0, 100.0);
            
            testCase.verifyClass(windage, 'double', ...
                'Метод moreParams должен возвращать double');
            testCase.verifyGreaterThan(windage, 0, ...
                'Баллистический коэффициент должен быть положительным');
        end
        
        function programVisualizationTest(testCase)
            % Тест 7: Программа может создавать визуализацию без ошибок
            
            z = ZakovikaClass(300E3,0,0);
            % Выполняем несколько шагов для создания данных
            z.iterate(0.1, 1.0);
            
            % Проверяем методы визуализации
            try
                z.draw();
                drawExecutionSuccessful = true;
            catch
                drawExecutionSuccessful = false;
            end
            
            testCase.verifyTrue(drawExecutionSuccessful, ...
                'Метод draw должен выполняться без ошибок');
            try
                z.plotVelocity();
                velocityExecutionSuccessful = true;
            catch
                velocityExecutionSuccessful = false;
            end
            
            testCase.verifyTrue(velocityExecutionSuccessful, ...
                'Метод plotVelocity должен выполняться без ошибок');
            try
                z.plotTrajectory();
                trajectoryExecutionSuccessful = true;
            catch
                trajectoryExecutionSuccessful = false;
            end
            
            testCase.verifyTrue(trajectoryExecutionSuccessful, ...
                'Метод plotTrajectory должен выполняться без ошибок');
        end
     end
 end