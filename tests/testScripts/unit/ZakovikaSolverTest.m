classdef ZakovikaSolverTest < matlab.unittest.TestCase

    methods (TestClassTeardown)
        function teardown(~)
        clearvars;
        end
    end
    
    methods
        function testOrbitalVelocityCalculation(testCase)
            % Тест расчета орбитальной скорости по формуле v = sqrt(GM/r)
            
            z = ZakovikaClass(300E3,0,0);
            % Тест на высоте 300 км
            height = 300e3; % 300 км
            expectedVelocityRange = [7.7e3, 7.8e3]; %Expected range in m/s
            calculatedVelocity = z.v1Space(height);
            
            testCase.verifyGreaterThanOrEqual(calculatedVelocity, expectedVelocityRange(1), ...
                'Скорость должна быть в ожидаемом диапазоне (нижняя граница)');
            testCase.verifyLessThanOrEqual(calculatedVelocity, expectedVelocityRange(2), ...
                'Скорость должна быть в ожидаемом диапазоне (верхняя граница)');
            
            % Тест монотонного убывания скорости с высотой
            heights = [200e3, 300e3, 400e3, 500e3];
            velocities = zeros(1, length(heights));
            
            for i = 1:length(heights)
                velocities(i) = z.v1Space(heights(i));
            end
            
            % Скорость должна убывать с высотой
            for i = 2:length(velocities)
                testCase.verifyLessThan(velocities(i), velocities(i-1), ...
                    sprintf('Скорость на высоте %.0f км должна быть меньше, чем на %.0f км', ...
                    heights(i)/1000, heights(i-1)/1000));
            end
        end
        
        function testAtmosphereDensityCalculation(testCase)
            % Тест расчета плотности атмосферы по формуле ρ = ρ₀ * exp(-h/H)
            
            z = ZakovikaClass(300E3,0,0);

            % Тест на уровне моря
            seaLevelDensity = z.ro(0);
            testCase.verifyEqual(seaLevelDensity, 1.2255, ...
                'Плотность на уровне моря должна быть 1.2255 кг/м³');
            
            % Тест экспоненциального убывания
            densityH0 = z.ro(0);
            densityH30 = z.ro(30e3); % 30 км
            
            % На высоте 30 км плотность должна быть в e раз меньше
            expectedDensityH30 = densityH0 / exp(1);
            testCase.verify_equal(densityH30, expectedDensityH30, ...
                'RelTol', 1e-10, 'Плотность на высоте 30 км должна быть в e раз меньше');
            
            % Тест на очень большой высоте (практически вакуум)
            densityHigh = z.ro(300e3); % 300 км
            testCase.verifyLessThan(densityHigh, 1e-6, ...
                'Плотность на высоте 300 км должна быть очень маленькой');
            
            % Тест монотонного убывания плотности
            testHeights = [0, 10e3, 20e3, 50e3, 100e3];
            densities = zeros(1, length(testHeights));
            
            for i = 1:length(testHeights)
                densities(i) = z.ro(testHeights(i));
            end
            
            for i = 2:length(densities)
                testCase.verifyLessThan(densities(i), densities(i-1), ...
                    'Плотность должна монотонно убывать с высотой');
            end
        end
        
        function testDragForceCalculation(testCase)
            % Тест расчета силы сопротивления по формуле F = 0.5 * C_x * S * ρ * v²
            % Источник: аэродинамика, формула лобового сопротивления
            
            z = ZakovikaClass(300E3,0,0);

            height = 100e3; % 100 км
            velocity = 7500; % 7.5 км/с
            
            % Расчет ожидаемой силы
            density = z.ro(height);
            expectedDragForce = 0.5 * 2.5 * 1.0 * density * velocity^2;
            
            calculatedDragForce = z.frictionForce(height, velocity);
            
            testCase.verifyEqual(calculatedDragForce, expectedDragForce, ...
                'RelTol', 1e-10, 'Сила сопротивления должна соответствовать формуле');
            
            % Тест граничных случаев
            % Нулевая скорость -> нулевая сила
            zeroVelocityForce = z.frictionForce(height, 0);
            testCase.verifyEqual(zeroVelocityForce, 0, ...
                'При нулевой скорости сила сопротивления должна быть нулевой');
            
            % Нулевая плотность -> нулевая сила
            zeroDensityForce = z.frictionForce(1e6, velocity); % Очень большая высота
            testCase.verifyLessThan(zeroDensityForce, 1e-10, ...
                'При нулевой плотности сила сопротивления должна быть нулевой');
            
            % Тест пропорциональности квадрату скорости
            forceV1 = z.frictionForce(height, 1000);
            forceV2 = z.frictionForce(height, 2000);
            testCase.verifyEqual(forceV2, 4 * forceV1, ...
                'RelTol', 1e-10, 'Сила сопротивления должна быть пропорциональна квадрату скорости');
        end
        
        function testNumericalStepConsistency(testCase)
            % Тест согласованности численного интегрирования
            
            z = ZakovikaClass(300E3,0,0);

            % Выполняем один шаг
            newHeight = z.iterate(timeStep,timeStep);
            
            % Проверки физической согласованности
            testCase.verifyGreaterThan(newHeight, 0, ...
                'Высота должна оставаться положительной');
            
            % Новый радиус должен равняться старому + изменение высоты
            expectedRadius = (newHeight + z.earthR);
            testCase.verifyEqual(z.radiusArray(1), expectedRadius, ...
                'Радиус должен изменяться согласованно с высотой');
            
            % Проверка сохранения в массивы
            testCase.verifyLength(z.radiusArray, 1, ...
                'В массив радиусов должно добавиться одно значение');
            testCase.verifyLength(z.fiArray, 1, ...
                'В массив углов должно добавиться одно значение');
            testCase.verifyLength(z.velocityArray, 1, ...
                'В массив скоростей должно добавиться одно значение');
        end
        
        function testPhysicalConstants(testCase)
            % Тест физических констант на соответствие реальным значениям
            % Источник: справочные физические константы
            
            % Радиус Земли
            testCase.verifyGreaterThan(z.earthR, 6.3e6, ...
                'Радиус Земли должен быть > 6300 км');
            testCase.verifyLessThan(z.earthR, 6.5e6, ...
                'Радиус Земли должен быть < 6500 км');
            
            % Масса Земли
            testCase.verifyGreaterThan(z.earthM, 5.9e24, ...
                'Масса Земли должна быть > 5.9×10²⁴ кг');
            testCase.verifyLessThan(z.earthM, 6.0e24, ...
                'Масса Земли должна быть < 6.0×10²⁴ кг');
            
            % Гравитационная постоянная
            testCase.verifyGreaterThan(z.constG, 6.6e-11, ...
                'Гравитационная постоянная должна быть > 6.6×10⁻¹¹');
            testCase.verifyLessThan(z.constG, 6.7e-11, ...
                'Гравитационная постоянная должна быть < 6.7×10⁻¹¹');
        end
    end
end