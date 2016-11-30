%TestYUV.m
clear;clc;
%addpath('./Codes/YUV_RW');
%addpath('./Codes/Videos');
%Video Info
filename = 'foreman_cif_300f.yuv';
format = 'cif';
init2last = [0,100];
file_cnt = length(filename);
%Parameters
blk_sz = 16;
sch_rd = 8;
enb_sz_me = 0;
enb_sz_mc = 8;
rf_rd  = 2;
%Read YUV
[Y,U,V] = ReadMultiFrames(filename,format,init2last);
y1=impyramid(Y,'reduce');
u1=impyramid(U,'reduce');
v1=impyramid(V,'reduce');
enb_sz_me1=enb_sz_me/2;
enb_sz_mc1=enb_sz_mc/2;
[a,b,c]=size(Y);
disp(c);
sch_rd1=sch_rd;
[im_rows,im_cols,video_len] = size(y1);
disp(video_len);
blk_rows = fix(im_rows/blk_sz);		
blk_cols = fix(im_cols/blk_sz);
PSNR_Y = [];
SSIM_Y = []; 
p1=[]
TIME_Y = [];
blk_szl1=blk_sz/2;
%MVFf_blk_pre1 = zeros(fix(im_rows/blk_sz),fix(im_cols/blk_sz),2);
%MVFb_blk_pre1 = zeros(fix(im_rows/blk_sz),fix(im_cols/blk_sz),2);
Pos = [-1,-1,-1, 0;-1, 0, 1,-1];
%MVFf_blk_pre = zeros(im_rows/blk_szl1,im_cols/blk_szl1,2);
%MVFb_blk_pre = zeros(im_rows/blk_szl1,im_cols/blk_szl1,2);
%disp(size(MVFb_blk_pre));
for tt = 2:2:video_len
    disp(sprintf('The %d-th Frame.',tt));
    imC_Y   = y1(:,:,tt);
    imR1_Y  = y1(:,:,tt-1);
    imR2_Y  = y1(:,:,tt+1);
    tic
    %Forward
    %MVFf_blk_Y =  BMA_3DRS(imR2_Y,imR1_Y,MVFf_blk_pre,blk_sz,enb_sz_me);
    MVFf_blk_Y = BMA_FS(imR2_Y,imR1_Y,blk_szl1,enb_sz_me1,sch_rd1);
 %   disp(size(MVFf_blk_Y));
    MVFf_blk_Y = SmoothMVF(MVFf_blk_Y);
   % MVFf_blk_pre1 = MVFf_blk_Y;
    MVFf_blk_Y = round(MVFf_blk_Y/2); %Parallel Assumption
    MVFf_blk_Y = BiRefine(MVFf_blk_Y,imR1_Y,imR2_Y,blk_szl1,enb_sz_me1,rf_rd);
    %Backward
    %MVFb_blk_Y =  BMA_3DRS(imR1_Y,imR2_Y,MVFb_blk_pre,blk_sz,enb_sz_me);
    MVFb_blk_Y = BMA_FS(imR1_Y,imR2_Y,blk_szl1,enb_sz_me1,sch_rd1);
    
    MVFb_blk_Y = SmoothMVF(MVFb_blk_Y);
   MVFb_blk_pre = MVFb_blk_Y;
    fprintf('change');
    %disp(size(MVFf_blk_pre1));
    MVFb_blk_Y = round(MVFb_blk_Y/2); %Parallel Assumption
    MVFb_blk_Y = BiRefine(MVFb_blk_Y,imR2_Y,imR1_Y,blk_szl1,enb_sz_me1,rf_rd);
   % fprintf('sdaasdaaaaaad');
   
    imP_Y1 = DS_OBMC(imR1_Y,imR2_Y,MVFf_blk_Y,MVFb_blk_Y,blk_szl1,enb_sz_me1,enb_sz_mc1);
     p2=Psnr(imP_Y1,imC_Y);
     p1=[p1,p2];
%
    imP_kk=Y(:,:,tt-1);
    imF_kk=Y(:,:,tt+1);
    i1=imP_kk;
    i2=imF_kk;
    i3=Y(:,:,tt);
    MVFf_blk_pre = MVFf_blk_Y;
    im_rows_kk= im_rows*2;        
    im_cols_kk = im_cols*2;
    blk_sz_kk = blk_sz;
    enb_sz_kk =enb_sz_mc;
    ext_sz_kk = 2*max(abs(MVFf_blk_Y(:)))+enb_sz_kk+rf_rd+7*blk_sz_kk;
    imP_kk = imextend1(imP_kk,ext_sz_kk);
    imF_kk = imextend1(imF_kk,ext_sz_kk);
    for ii = 1+ext_sz_kk:blk_sz_kk:im_rows_kk+ext_sz_kk
        for jj = 1+ext_sz_kk:blk_sz_kk:im_cols_kk+ext_sz_kk
            blk_ii = fix((ii-ext_sz_kk-1)/blk_sz_kk) + 1;
            blk_jj = fix((jj-ext_sz_kk-1)/blk_sz_kk) + 1;
            CS = [];
            csb=[];
            for mm = -1:1
                for nn = -1:1
                    blk_ii_pre = blk_ii + mm; 
                    blk_jj_pre = blk_jj + nn;
                    blk_ii_preb = blk_ii + mm; 
                    blk_jj_preb = blk_jj + nn;
                    
                    if (blk_ii_pre>=1)&&(blk_ii_pre<=blk_rows)&&...
                            (blk_jj_pre>=1)&&(blk_jj_pre<=blk_cols)
                       % if ((mm==-1)&&(nn==-1))||((mm==-1)&&(nn==1))||...
                       %((mm==1)&&(nn==-1))||((mm==1)&&(nn==1))
                       %     continue;
                      %  else
                            temp = 2*[MVFf_blk_pre(blk_ii_pre,blk_jj_pre,1);...
                                MVFf_blk_pre(blk_ii_pre,blk_jj_pre,2)];
                            temp1 = 2*[MVFb_blk_pre(blk_ii_preb,blk_jj_preb,1);...
                                MVFb_blk_pre(blk_ii_preb,blk_jj_preb,2)];
                            CS = [CS,temp];
                            csb=[csb,temp1];
                       % end
                    end
                end
            end
            for tt1 = 1:size(Pos,2)
                pos = Pos(:,tt1);
                blkn_ii = blk_ii + pos(1); 
                blkn_jj = blk_jj + pos(2);
                if (blkn_ii>=1)&&(blkn_ii<=blk_rows)&&...
                        (blkn_jj>=1)&&(blkn_jj<=blk_cols)
                    temp = [MVFf_blk_Y(blkn_ii,blkn_jj,1);...
                        MVFf_blk_Y(blkn_ii,blkn_jj,2)];
                    CS = [CS,temp];
                     temp1 = [MVFb_blk_Y(blkn_ii,blkn_jj,1);...
                        MVFb_blk_Y(blkn_ii,blkn_jj,2)];
                    csb = [csb,temp1];
                end
            end       
            CS = unique(CS','rows');
            csb=unique(csb','rows');
            CS = CS';
            csb=csb';
            CS_cnt = size(CS,2);
            min_cost = -1;
            for tt1 = 1:CS_cnt
                MV = CS(:,tt1);
                iiPI = ii + MV(1);
                jjPI = jj + MV(2);
                for iiP = iiPI-rf_rd:iiPI+rf_rd
                    for jjP = jjPI-rf_rd:jjPI+rf_rd
                        blkP = imP_kk(iiP-enb_sz_kk:iiP+enb_sz_kk+...
                            blk_sz_kk-1,jjP-enb_sz_kk:jjP+enb_sz_kk+blk_sz_kk-1,:);
                        MV_ii = iiP - ii;
                        MV_jj = jjP - jj;
                        iiF = ii - MV_ii;
                        jjF = jj - MV_jj;
                        blkF = imF_kk(iiF-enb_sz_kk:iiF+enb_sz_kk+...
                            blk_sz_kk-1,jjF-enb_sz_kk:jjF+enb_sz_kk+blk_sz_kk-1,:);
                        cost = CostFun(blkP,blkF);
                        
                        if (min_cost<0)||(cost<min_cost)
                            min_cost = cost;
                            MVbest_ii = MV_ii;
                            MVbest_jj = MV_jj;
                        end
                    end
                end
                
                MVFf_blk_Y(blk_ii,blk_jj,1) = MVbest_ii;
                MVFf_blk_Y(blk_ii,blk_jj,2) = MVbest_jj;
            end
            CS_cntb = size(csb,2);
            min_cost = -1;
             for tt1 = 1:CS_cntb
                MVb = csb(:,tt1);
                iiPIb = ii + MVb(1);
                jjPIb = jj + MVb(2);
                for iiP = iiPIb-rf_rd:iiPIb+rf_rd
                    for jjP = jjPIb-rf_rd:jjPIb+rf_rd
                        blkP = imP_kk(iiP-enb_sz_kk:iiP+enb_sz_kk+...
                            blk_sz_kk-1,jjP-enb_sz_kk:jjP+enb_sz_kk+blk_sz_kk-1,:);
                        MV_ii = iiP - ii;
                        MV_jj = jjP - jj;
                        iiF = ii - MV_ii;
                        jjF = jj - MV_jj;
                        blkF = imF_kk(iiF-enb_sz_kk:iiF+enb_sz_kk+...
                            blk_sz_kk-1,jjF-enb_sz_kk:jjF+enb_sz_kk+blk_sz_kk-1,:);
                        cost = CostFun(blkP,blkF);
                        
                        if (min_cost<0)||(cost<min_cost)
                            min_cost = cost;
                            MVbest_ii = MV_ii;
                            MVbest_jj = MV_jj;
                        end
                    end
                end
                
                MVFb_blk_Y(blk_ii,blk_jj,1) = MVbest_ii;
                MVFb_blk_Y(blk_ii,blk_jj,2) = MVbest_jj;
            end
        end
    end
     MVFf_blk_Y = SmoothMVF(MVFf_blk_Y);
   
    MVFf_blk_Y = round(MVFf_blk_Y/2); %Parallel Assumption
    
    MVFf_blk_pre = BiRefine(MVFf_blk_Y,i1,i2,blk_sz,enb_sz_me,rf_rd);
  MVFb_blk_Y = SmoothMVF(MVFb_blk_Y);
    MVFb_blk_pre = round(MVFb_blk_Y/2); %Parallel Assumption
    MVFb_blk_pre = BiRefine(MVFb_blk_pre,i2,i1,blk_sz,enb_sz_me,rf_rd);
    
%     fprintf('sdaasdasdasdasd');
%         disp(size(MVFf_blk_pre));
%             disp(size(i1));            
% disp(blk_szl1);
%                 disp(enb_sz_me1);
%                 disp(enb_sz_mc1);


    imP_Y = DS_OBMC(i1,i2,MVFf_blk_pre,MVFb_blk_pre,blk_sz,enb_sz_me,enb_sz_mc);
   
    
   
 %   
    %disp(imP_Y);
    %disp(imC_Y);
    time = toc;
    psnr_Y = Psnr(i3,imP_Y);
    ssim_Y = ssim(i3,imP_Y);
%     fprintf('sashjasd')
%     disp(psnr_Y);
%     disp(size(i3));
%     disp(size(MVFf_blk_pre));
    if (psnr_Y< 500)
         PSNR_Y = [PSNR_Y,psnr_Y]
    end
    SSIM_Y = [SSIM_Y,ssim_Y];
    TIME_Y = [TIME_Y,time];
    %Update
    Y(:,:,tt) = imP_Y;
end34.79

TIME_mean = mean(TIME_Y);
p11=mean(p1);
PSNR_Y_mean = mean(PSNR_Y);
SSIM_Y_mean = mean(SSIM_Y);
disp(sprintf('Y  : The Mean P11 = %.2f dB',p11));
disp(sprintf('Y  : The Mean PSNR = %.2f dB',PSNR_Y_mean));
disp(sprintf('Y  : The Mean SSIM = %.4f',SSIM_Y_mean));
disp(sprintf('The Mean Time      = %.2f s',TIME_mean));
