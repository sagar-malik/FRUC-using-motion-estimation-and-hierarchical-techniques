function cost = CostFun(blkC,blkR)

cost = sum(abs(blkC(:)-blkR(:))); %SAD
%cost = sum((blkC(:)-blkR(:)).^2); %SSD

