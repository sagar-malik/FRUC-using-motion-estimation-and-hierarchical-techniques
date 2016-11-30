function MVF_blk = BiRefine(MVF_blkC,imR1,imR2,blk_sz,enb_sz,rf_rd)

ext_sz = max(abs(MVF_blkC(:))) + enb_sz + rf_rd + blk_sz;
[im_rows,im_cols] = size(imR1);
blk_rows = im_rows/blk_sz;
blk_cols = im_cols/blk_sz;
imR1_pad = imextend(imR1,ext_sz);
imR2_pad = imextend(imR2,ext_sz);
MVF_blk = zeros(blk_rows,blk_cols,2);

for blk_ii = 1:blk_rows
    for blk_jj = 1:blk_cols
        ii = (blk_ii-1)*blk_sz + 1 + ext_sz;
        jj = (blk_jj-1)*blk_sz + 1 + ext_sz;
        MV1 = MVF_blkC(blk_ii,blk_jj,1);
        MV2 = MVF_blkC(blk_ii,blk_jj,2);
        iiR1 = ii + MV1;
        jjR1 = jj + MV2;
        min_cost = -1;
        for mm = iiR1-rf_rd:iiR1+rf_rd
            for nn = jjR1-rf_rd:jjR1+rf_rd
                blkR1 = imR1_pad(mm-enb_sz:mm+blk_sz+enb_sz-1,...
                    nn-enb_sz:nn+blk_sz+enb_sz-1);
                iiR2 = ii - (mm - ii);
                jjR2 = jj - (nn - jj);
                blkR2 = imR2_pad(iiR2-enb_sz:iiR2+blk_sz+enb_sz-1,...
                    jjR2-enb_sz:jjR2+blk_sz+enb_sz-1);
                cost = CostFun(blkR1,blkR2);
                if (min_cost<0)||(cost<min_cost)
                    min_cost = cost;
                    best_iiR1 = mm;
                    best_jjR1 = nn;
                end
            end
        end
        MVF_blk(blk_ii,blk_jj,1) = best_iiR1 - ii;
        MVF_blk(blk_ii,blk_jj,2) = best_jjR1 - jj;
    end
end

end
                
        
        
        