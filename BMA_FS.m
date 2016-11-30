function MVF_blk = BMA_FS(imC,imR,blk_sz,enb_sz,sch_rd)

ext_sz = sch_rd + enb_sz;
[im_rows,im_cols] = size(imC);
blk_rows = im_rows/blk_sz;
blk_cols = im_cols/blk_sz;

imC_pad = imextend(imC,ext_sz);
imR_pad = imextend(imR,ext_sz);
MVF_blk = zeros(blk_rows,blk_cols,2);

for ii = 1+ext_sz:blk_sz:im_rows+ext_sz
    for jj = 1+ext_sz:blk_sz:im_cols+ext_sz
        
        blk_ii = fix((ii-ext_sz-1)/blk_sz) + 1;
        blk_jj = fix((jj-ext_sz-1)/blk_sz) + 1;
        
        blkC = imC_pad(ii-enb_sz:ii+blk_sz+enb_sz-1,...
            jj-enb_sz:jj+blk_sz+enb_sz-1);
        min_cost = -1;
        for mm = ii-sch_rd:ii+sch_rd
            for nn = jj-sch_rd:jj+sch_rd
                blkR = imR_pad(mm-enb_sz:mm+blk_sz+enb_sz-1,...
                    nn-enb_sz:nn+blk_sz+enb_sz-1);
                cost = CostFun(blkC,blkR);
                if (min_cost<0)||(cost<min_cost)
                    min_cost = cost;
                    bestR_ii = mm;
                    bestR_jj = nn;
                end
            end
        end
        
        MVF_blk(blk_ii,blk_jj,1) = bestR_ii - ii;
        MVF_blk(blk_ii,blk_jj,2) = bestR_jj - jj;
        
    end
end

end
        
        
        
        

