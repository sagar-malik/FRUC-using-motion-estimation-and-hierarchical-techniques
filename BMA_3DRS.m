function MVF_blk = BMA_3DRS(imC,imR,MVF_blk_pre,blk_sz,enb_sz)

blk_rows = size(MVF_blk_pre,1);
blk_cols = size(MVF_blk_pre,2);
MVF_blk = zeros(blk_rows,blk_cols,2);

US  = [0,0, 0,0, 0,1,-1,3,-3;
       0,1,-1,2,-2,0, 0,0, 0];
p = 9;
offset = 200;
% PredPosDis = [-1,-1, 2, 2,-1,-1;
%               -1, 1,-2, 2,-1, 1];
PredPosDis = [ 0,-1, 0, 1,-1,-1;
              -1, 0, 1, 0,-1, 1];
ext_sz = enb_sz + max(abs(MVF_blk_pre(:))) + max(abs(US(:))) + 5*blk_sz;
imC_pad = imextend(imC,ext_sz);
imR_pad = imextend(imR,ext_sz);

blk_cnt = 0;
for blk_ii = 1:blk_rows
    for blk_jj = 1:blk_cols
        blk_cnt = blk_cnt + 1;
        CS = [0;0];
        ii = (blk_ii-1)*blk_sz + 1 + ext_sz;
        jj = (blk_jj-1)*blk_sz + 1 + ext_sz;
        blkC = imC_pad(ii-enb_sz:ii+blk_sz+enb_sz-1,...
                   jj-enb_sz:jj+blk_sz+enb_sz-1);
        for kk = 1:size(PredPosDis,2)
            blk_ii_pred = blk_ii + PredPosDis(1,kk);
            blk_jj_pred = blk_jj + PredPosDis(2,kk);
            if (blk_ii_pred>0)&&(blk_ii_pred<=blk_rows)&&(blk_jj_pred>0)&&...
                    (blk_jj_pred<=blk_cols)
                if kk<=2
                    D_pred = [MVF_blk(blk_ii_pred,blk_jj_pred,1);...
                              MVF_blk(blk_ii_pred,blk_jj_pred,2)];
                    CS = [CS,D_pred];
                elseif kk<=4
                    D_pred = [MVF_blk_pre(blk_ii_pred,blk_jj_pred,1);...
                              MVF_blk_pre(blk_ii_pred,blk_jj_pred,2)];
                    CS = [CS,D_pred];
                elseif kk==5
                    D_pred = [MVF_blk(blk_ii_pred,blk_jj_pred,1);...
                              MVF_blk(blk_ii_pred,blk_jj_pred,2)];
                    d = mod(blk_cnt,p);
                    D_pred = D_pred + US(:,d+1);
                    CS = [CS,D_pred];
                else
                    D_pred = [MVF_blk(blk_ii_pred,blk_jj_pred,1);...
                              MVF_blk(blk_ii_pred,blk_jj_pred,2)];
                    d = mod(blk_cnt+offset,p);
                    D_pred = D_pred + US(:,d+1);
                    CS = [CS,D_pred];
                end
            end
        end
        CS_cnt = size(CS,2);
        min_cost = -1;
        for kk = 1:CS_cnt
            D_pred = CS(:,kk);
            iiR = ii + D_pred(1);
            jjR = jj + D_pred(2);
            blkR = imR_pad(iiR-enb_sz:iiR+blk_sz+enb_sz-1,...
                jjR-enb_sz:jjR+blk_sz+enb_sz-1);
            cost = CostFun(blkC,blkR);
            if (min_cost<0)||(cost<min_cost)
                min_cost = cost;
                MV_best1 = D_pred(1);
                MV_best2 = D_pred(2);
            end
        end
        MVF_blk(blk_ii,blk_jj,1) = MV_best1;
        MVF_blk(blk_ii,blk_jj,2) = MV_best2;
    end
end


end
