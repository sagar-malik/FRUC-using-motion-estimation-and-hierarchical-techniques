function MVF_blk_proc = SmoothMVF(MVF_blk)

blk_rows = size(MVF_blk,1);
blk_cols = size(MVF_blk,2);


PredPosDis = [-1,-1,-1, 0, 0, 1, 1, 1;
              -1, 0, 1,-1, 1,-1, 0, 1];
sty = [1/sqrt(2),1,1/sqrt(2),1,1,1/sqrt(2),1,1/sqrt(2)];
error = zeros(blk_rows,blk_cols);
%Check Error
for blk_ii = 1:blk_rows
    for blk_jj = 1:blk_cols
        MV0 = [MVF_blk(blk_ii,blk_jj,1);MVF_blk(blk_ii,blk_jj,2)];
        CS = [];
        for kk = 1:size(PredPosDis,2)
            blk_ii_pred = blk_ii + PredPosDis(1,kk);
            blk_jj_pred = blk_jj + PredPosDis(2,kk);
            if (blk_ii_pred>0)&&(blk_ii_pred<=blk_rows)&&(blk_jj_pred>0)&&...
                    (blk_jj_pred<=blk_cols)
                MV = [MVF_blk(blk_ii_pred,blk_jj_pred,1);...
                    MVF_blk(blk_ii_pred,blk_jj_pred,2)];
                CS = [CS,MV];
            end
        end
        MVm = mean(CS,2);
        D0 = sum((MV0-MVm).^2);
        CS_cnt = size(CS,2);
        Dm = mean(sum((repmat(MVm,1,CS_cnt)-CS).^2));
        if D0>Dm
            error(blk_ii,blk_jj) = 1;
        end
    end
end
%Correct Error
for blk_ii = 1:blk_rows
    for blk_jj = 1:blk_cols
        if error(blk_ii,blk_jj)
            CS = []; alpha = [];
            for kk = 1:size(PredPosDis,2)
                blk_ii_pred = blk_ii + PredPosDis(1,kk);
                blk_jj_pred = blk_jj + PredPosDis(2,kk);
                temp = sty(kk);
                if (blk_ii_pred>0)&&(blk_ii_pred<=blk_rows)&&(blk_jj_pred>0)&&...
                        (blk_jj_pred<=blk_cols)
                    if ~error(blk_ii_pred,blk_jj_pred)
                        MV = [MVF_blk(blk_ii_pred,blk_jj_pred,1);...
                            MVF_blk(blk_ii_pred,blk_jj_pred,2)];
                        CS = [CS,MV];
                        alpha = [alpha,temp];
                    end
                end
            end
            if ~isempty(alpha)
                w = alpha/sum(alpha);
                MV0c = round(sum(CS.*[w;w],2));
                MVF_blk(blk_ii,blk_jj,1) = MV0c(1);
                MVF_blk(blk_ii,blk_jj,2) = MV0c(2);
				error(blk_ii,blk_jj) = 0;
            end
        end
    end
end
MVF_blk_proc = MVF_blk;
end
 
  


