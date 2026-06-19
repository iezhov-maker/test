import pkg.Zakovika_class.*

z = ZakovikaClass(300E3,0,0); %z.v1Space(300E3)/(2*pi)

tau = 1.e-2;
z.iterate(tau,200*1000*tau);
%todo: график Зависимость скорости КА от времени
%todo: Траекторию движения КА в полярных координатах вокруг Земли

z.draw();
%z.plotVelocity();
%z.plotTrajectory();
