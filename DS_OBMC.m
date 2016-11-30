function imP = DS_OBMC(imR1,imR2,MVF_blkf,MVF_blkb,blk_sz,enb_sz_me,enb_sz_mc)

[im_rows,im_cols] = size(imR1);
ext_sz = enb_sz_mc + enb_sz_me + max(abs([MVF_blkf(:);MVF_blkb(:)])) + 3*blk_sz;
imR1_pad = imextend(imR1,ext_sz);
imR2_pad = imextend(imR2,ext_sz);
imP_pad = imextend(zeros(im_rows,im_cols),ext_sz);
num_pad = imP_pad;

for ii = 1+ext_sz:blk_sz:im_rows+ext_sz
    for jj = 1+ext_sz:blk_sz:im_cols+ext_sz
        
        blk_ii = (ii-ext_sz-1)/blk_sz + 1;
        blk_jj = (jj-ext_sz-1)/blk_sz + 1;
        
        %Forward
        MVf = [MVF_blkf(blk_ii,blk_jj,1);MVF_blkf(blk_ii,blk_jj,2)];
        iiR1 = ii + MVf(1);
        jjR1 = jj + MVf(2);
        blkR1 = imR1_pad(iiR1-enb_sz_me:iiR1+blk_sz+enb_sz_me-1,...
            jjR1-enb_sz_me:jjR1+blk_sz+enb_sz_me-1);
        iiR2 = ii - MVf(1);
        jjR2 = jj - MVf(2);
        blkR2 = imR2_pad(iiR2-enb_sz_me:iiR2+blk_sz+enb_sz_me-1,...
            jjR2-enb_sz_me:jjR2+blk_sz+enb_sz_me-1);
        costf = CostFun(blkR1,blkR2);
        %Backward
        MVb = [MVF_blkb(blk_ii,blk_jj,1);MVF_blkb(blk_ii,blk_jj,2)];
        iiR1 = ii - MVb(1);
        jjR1 = jj - MVb(2);
        blkR1 = imR1_pad(iiR1-enb_sz_me:iiR1+blk_sz+enb_sz_me-1,...
            jjR1-enb_sz_me:jjR1+blk_sz+enb_sz_me-1);
        iiR2 = ii + MVb(1);
        jjR2 = jj + MVb(2);
        blkR2 = imR2_pad(iiR2-enb_sz_me:iiR2+blk_sz+enb_sz_me-1,...
            jjR2-enb_sz_me:jjR2+blk_sz+enb_sz_me-1);
        costb = CostFun(blkR1,blkR2);
        
        if costf<=costb
            iiR1 = ii + MVf(1);
            jjR1 = jj + MVf(2);
            blkR1 = imR1_pad(iiR1-enb_sz_mc:iiR1+enb_sz_mc+blk_sz-1,...
                jjR1-enb_sz_mc:jjR1+enb_sz_mc+blk_sz-1,1);
            iiR2 = ii - MVf(1);
            jjR2 = jj - MVf(2);
            blkR2 = imR2_pad(iiR2-enb_sz_mc:iiR2+enb_sz_mc+blk_sz-1,...
                jjR2-enb_sz_mc:jjR2+enb_sz_mc+blk_sz-1,1);
            temp = imP_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1);
            imP_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1) = temp + (blkR1+blkR2)/2;
            temp = num_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1);
            num_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1) = temp + 1;
                
        else

            iiR1 = ii - MVb(1);
            jjR1 = jj - MVb(2);
            blkR1 = imR1_pad(iiR1-enb_sz_mc:iiR1+enb_sz_mc+blk_sz-1,...
                jjR1-enb_sz_mc:jjR1+enb_sz_mc+blk_sz-1,1);
            iiR2 = ii + MVb(1);
            jjR2 = jj + MVb(2);
            blkR2 = imR2_pad(iiR2-enb_sz_mc:iiR2+enb_sz_mc+blk_sz-1,...
                jjR2-enb_sz_mc:jjR2+enb_sz_mc+blk_sz-1,1);
            temp = imP_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1);
            imP_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1) = temp + (blkR1+blkR2)/2;
            temp = num_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1);
            num_pad(ii-enb_sz_mc:ii+enb_sz_mc+blk_sz-1,...
                jj-enb_sz_mc:jj+enb_sz_mc+blk_sz-1) = temp + 1;

        end
    end
end
imP = imP_pad(1+ext_sz:im_rows+ext_sz,1+ext_sz:im_cols+ext_sz);
num = num_pad(1+ext_sz:im_rows+ext_sz,1+ext_sz:im_cols+ext_sz);
imP = imP./num;
end

        
        