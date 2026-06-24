import pkg.Zakovika_class.*

z = ZakovikaClass(500E3,0,0); %z.v1Space(300E3)/(2*pi)
z.moreParams(0.01,0.001,1); % cx, S, m
z.moreParams(0.01,0.1,1);
z.moreParams(0.01,1,1);

tau = 5e-1;
z.iterate(tau,10000);

z.draw();
z.plotBeta();
z.plotFriction();
z.plotVelocity();
z.plotTrajectory();
