function [Y,U,V] = yuv2mat(yuvfilename,format,frames_num) 
%该函数用于将yuv格式的视频逐帧分别读入到三维数组Y,U,V之中
%yuv视频的采样格式为4：2：0
%输入参数：
%      yuvfilename  ---- 视频yuv文件路径名
%      format       ---- 视频格式(格式名or分辨率[rows,cols])
%      frames_num   ---- 读取的视频帧数(原yuv视频的前frames_num帧)
%输出参数：
%         Y         ---- 亮度，三维数组，第三维为帧序号，前两维是单帧的行和列
%        U,V        ---- 色差，三维数组，第三维为帧序号，前两维是单帧的行和列
%调用示范：
%  [Y,U,V] = yuv2mat('.\videoname.yuv','cif',100);
%  [Y,U,V] = yuv2mat('.\videoname.yuv',[288,352],100);
close all;
if ischar(format)
  format = lower(format);
  switch format
      case 'sub_qcif'
          cols = 128; rows = 96;
      case 'qcif'
          cols = 176; rows = 144;
      case 'cif'
          cols = 352; rows = 288;
      case 'sif'
          cols = 352; rows = 240;
      case '4cif'
          cols = 704; rows = 576;
      otherwise
          error('no format!');
  end
elseif isequal(size(format),[1,2])||isequal(size(format),[2,1])
    cols = format(2);rows = format(1);
else
    error('第二参数输入有误！');
end

%读入视频帧
Y = zeros(rows,cols,frames_num);
U = zeros(rows/2,cols/2,frames_num);
V = U;

k = 0; %记录读取的帧序号
point = fopen(yuvfilename,'r');
if point == -1
    error('打开文件失败！');
end
for ii = 1:frames_num
    k = k + 1;
    pro = fread(point,1,'uchar');
    if feof(point)&&isempty(pro)
        disp(['读取帧数已超过yuv视频总帧数(',num2str(k-1),'帧)！']);
        Y = Y(:,:,1:k-1);
        U = U(:,:,1:k-1);
        V = V(:,:,1:k-1);
        break;
    end
    fseek(point,-1,'cof');
    temp = fread(point,[cols,rows],'uchar');
    Y(:,:,ii) = temp';
    temp = fread(point,[cols/2,rows/2],'uchar');
    U(:,:,ii) = temp';
    temp = fread(point,[cols/2,rows/2],'uchar');
    V(:,:,ii) = temp';
end
fclose(point);

end

        