% Calibration routine by Andrea and Pasquale Cirillo www.aepwebmasters.it
% Adapted to FreeIMU library by Fabio Varesano www.varesano.net
% Released under GPL v3 - See See http://www.gnu.org/copyleft/gpl.html

function SpherePlot(X, Y, Z, graph_title, filename)
  figure;
  subplot(2,2,1); plot3(X,Y,Z);
  title(graph_title);
  subplot(2,2,2); plot(X, Y);
  title('Vector projection on XY');
  subplot(2,2,3); plot(Y,Z);
  title('Vector projection on YZ');
  subplot(2,2,4); plot(Z,X);
  title('Vector projection on ZX');
  print(filename) % .pdf graphs generated
endfunction


function [OSx, OSy, OSz, SCx, SCy, SCz] = Ellipsoid_to_Sphere(data, graph_filename)
  
  SpherePlot(data(:,1), data(:,2), data(:,3), 'Uncalibrated data', strcat(graph_filename, '_uncalibrated.pdf'));

  %X=pinv([data(:,1) data(:,2) data(:,3) -data(:,2).^2 -data(:,3).^2 ones(size(data,1),1)])*(data(:,1).^2);
  %[data(:,2) -data(:,2).^2 -(data(:,2).^2)]
  H = [data(:,1) data(:,2) data(:, 3) -data(:,2).^2 -data(:,3).^2 ones(size(data,1),1)];
  w = data(:,1).^2;
  X = H \ w;
  OSx=X(1)/2;
  OSy=X(2)/(2*X(4));
  OSz=X(3)/(2*X(5));
  A=X(6)+OSx^2+X(4)*OSy^2+X(5)*OSz^2;
  B=A/X(4);
  C=A/X(5);
  SCx=sqrt(A);
  SCy=sqrt(B);
  SCz=sqrt(C);

  xx=data(:,1)-OSx;
  yy=data(:,2)-OSy;
  zz=data(:,3)-OSz;

  xxx=xx./SCx;
  yyy=yy./SCy;
  zzz=zz./SCz;

  SpherePlot(xxx, yyy, zzz, 'Calibrated data', strcat(graph_filename, '_calibrated.pdf'));
  
endfunction




data = dlmread('acc.txt', ' ');
[A_OSx, A_OSy, A_OSz, A_SCx, A_SCy, A_SCz] = Ellipsoid_to_Sphere(data, 'acc');

data = dlmread('magn.txt', ' ');
[M_OSx, M_OSy, M_OSz, M_SCx, M_SCy, M_SCz] = Ellipsoid_to_Sphere(data, 'magn');


%storing values to calibration header
calfile = fopen('calibration.h', 'w');

fprintf(calfile, '/**\n * FreeIMU calibration header. Automatically generated by octave AccMagnCalib.m.\n * Do not edit manually unless you know what you are doing.\n*/\n\n');

fprintf(calfile, 'const int acc_off_x = %d;\n', A_OSx);
fprintf(calfile, 'const int acc_off_y = %d;\n', A_OSy);
fprintf(calfile, 'const int acc_off_z = %d;\n', A_OSz);
fprintf(calfile, 'const float acc_scale_x = %f;\n', A_SCx);
fprintf(calfile, 'const float acc_scale_y = %f;\n', A_SCy);
fprintf(calfile, 'const float acc_scale_z = %f;\n', A_SCz);

fprintf(calfile, '\n\n');

fprintf(calfile, 'const int magn_off_x = %d;\n', M_OSx);
fprintf(calfile, 'const int magn_off_y = %d;\n', M_OSy);
fprintf(calfile, 'const int magn_off_z = %d;\n', M_OSz);
fprintf(calfile, 'const float magn_scale_x = %f;\n', M_SCx);
fprintf(calfile, 'const float magn_scale_y = %f;\n', M_SCy);
fprintf(calfile, 'const float magn_scale_z = %f;\n', M_SCz);

fclose(calfile);

%pause();


