classdef ZakovikaClass < handle
    % Test task solve
    %   description of satellite fall

    properties
        % Физические константы
        earthR = 6400e3;
        earthM = 5.9722e24;
        constG = 6.67e-11;

        % Параметры атмосферы
        ro0 = 1.2255;
        H = 30E3

        % Параметры спутника
        cx = 2.5;
        midelS = 1;
        tau = 1.e-2;
        windage = 1e-2;
        m
        
        t = 0;
        h
        fi = 0;
        fiDerivative = 0; %v1_space(h)/(2*pi)
        radius
        radiusDerivative = 0;
        beta = 2*pi/180;
        
        radiusArray = [];
        fiArray = [];
        velocityArray = [];

    end

    methods
        function obj = ZakovikaClass(h,fi,fiDerivative)
            % Входные параметры:
            %   h (double) - Начальная высота над поверхностью Земли, м
            %   fi (double) - Начальный полярный угол, рад
            %   fiDerivative (double) - Начальная угловая скорость, рад/с

            arguments
                h (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
                fi (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
                fiDerivative (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
            obj.m = obj.midelS / obj.windage;
            obj.radius = obj.earthR+h;
            obj.h = h;
            obj.fi = fi;
            % Если угловая скорость равна нулю, рассчитываем для круговой орбиты
            if fiDerivative == 0
                obj.fiDerivative = obj.v1Space(h) / obj.radius;
            else
                obj.fiDerivative = fiDerivative;
            end
        end

        function result = moreParams(obj, cx, S, m)
            arguments
                obj (:, 1) {mustBeNonempty}
                cx (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
                S (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
                m (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
            obj.cx = cx;
            obj.midelS = S;
            obj.m = m;
            result = S/m;
        end

        function result = iterate(obj, tau, tEnd)
            arguments
                obj (:, 1) {mustBeNonempty}
                tau (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
                tEnd (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
            while(obj.t < tEnd)
                hh = obj.numStep();
                obj.t = obj.t + tau;
                if hh<=0
                  break;
                end
            end
            result = hh;
        end

        function draw(obj)
            % Построение зависимостей радиуса и угла от шага по времени

            arguments
                obj (:, 1) {mustBeNonempty}
            end
            xLine = 1:1:length(obj.radiusArray);
            subplot(1, 2, 1);
            plot(xLine,obj.radiusArray);
            xlabel('N');
            ylabel('Radius')
            %plot(obj.radiusArray);
            subplot(1, 2, 2);
            plot(xLine,obj.fiArray);
            xlabel('N');
            ylabel('Fi')
        end

        function plotVelocity(obj)
            % Построение скорости движения

            arguments
                obj (:,1) {mustBeNonempty}
            end
            xLine = 1:1:length(obj.velocityArray);
            plot(xLine,obj.velocityArray);
            xlabel('N');
            ylabel('V')
        end

        function plotTrajectory(obj)
            % Построение траектории движения в полярных координатах

            arguments
                obj (:,1) {mustBeNonempty}
            end
            
            figure('Name', 'Траектория падения спутника', 'Position', [150, 150, 800, 800]);
            
            % Преобразование в декартовы координаты
            x = obj.radiusArray .* cos(obj.fiArray) / 1000; % в км
            y = obj.radiusArray .* sin(obj.fiArray) / 1000; % в км
            
            hold on
            %Рисование Земли
            viscircles([0,0],obj.earthR/1000);
            
            % Построение траектории
            plot(x, y, 'b-', 'LineWidth', 2, 'DisplayName', 'Траектория спутника');
            hold on;
            
            % Маркировка начальной и конечной точек
            plot(x(1), y(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', 'Начало');
            if length(x) > 1
                plot(x(end), y(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', 'Конец');
            end
            
            % Настройка графика
            axis equal;
            grid on;
            xlabel('X, км');
            ylabel('Y, км');
            title('Траектория падения спутника в полярных координатах');
            legend('Location', 'best');
            
            % Установка пределов осей для лучшей видимости
            maxRadius = max(obj.radiusArray) / 1000;
            axis([-maxRadius*1.1, maxRadius*1.1, -maxRadius*1.1, maxRadius*1.1]);
            hold off
        end

        function result = v1Space(obj,h)
            arguments
                obj (:, 1) {mustBeNonempty}
                h  (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
          result = sqrt(obj.constG.*obj.earthM./(obj.earthR+h));
        end
        
        function result = ro(obj,h)
            arguments
                obj (:, 1) {mustBeNonempty}
                h  (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
          result = obj.ro0 * exp(-h/obj.H);
          end
          
        function result = frictionForce(obj,h)
            arguments
                obj (:, 1) {mustBeNonempty}
                h  (:, 1) {mustBeNonempty, mustBeNumeric, mustBeFinite}
            end
          result = obj.cx * obj.midelS * obj.ro(h) * obj.v1Space(h)^2 / 2;
        end

        function result = numStep(obj)
            arguments
                obj (:, 1) {mustBeNonempty}
            end
          radiusDerivativeNew = obj.radiusDerivative + obj.tau * ((obj.radius*obj.fiDerivative^2) - obj.constG*obj.earthM/obj.radius^2 + obj.frictionForce(obj.h)*sin(obj.beta)/obj.m);
          fiDerivativeNew = obj.fiDerivative + obj.tau / obj.radius * (obj.frictionForce(obj.h)*cos(obj.beta)/obj.m - 2*obj.fiDerivative*obj.radiusDerivative);
          radiusNew = obj.radius + obj.tau * radiusDerivativeNew;
          fiNew = obj.fi + obj.tau * fiDerivativeNew;
          hNew = radiusNew-obj.earthR;
          betanew = atan2(radiusNew-obj.radius, obj.tau*fiDerivativeNew*obj.radius);
        
          obj.h = hNew;
          obj.radius = radiusNew;
          obj.radiusDerivative = radiusDerivativeNew;
          obj.fi = fiNew;
          obj.fiDerivative = fiDerivativeNew;
          velocity = obj.fiDerivative * obj.earthR;
          obj.beta = betanew;
        
          obj.radiusArray = [obj.radiusArray obj.radius];
          obj.fiArray = [obj.fiArray (obj.fi)];
          obj.velocityArray = [obj.velocityArray velocity];
          obj.t = obj.t + obj.tau;
          result = obj.h;
        end
    end
end
