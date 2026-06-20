import pkg.Zakovika_class.*

z = ZakovikaClass(300E3,0,0); %z.v1Space(300E3)/(2*pi)

tau = 1.e-2;
z.iterate(tau,200*1000*tau);

%z.draw();
%z.plotVelocity();
z.plotTrajectory();
