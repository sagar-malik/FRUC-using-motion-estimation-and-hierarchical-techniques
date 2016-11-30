function im_ext = imextend(im,ext_sz)      %take reflection of im and extends dimensions by ext_sz in all directions 
					%image is symmetric and mirror reflected			
cnt = size(im,3);
im_ext = [];
for kk = 1:cnt
    im_kk = im(:,:,kk);
    im_kk = padarray(im_kk,[ext_sz,ext_sz],'symmetric','both');
    im_ext = cat(3,im_ext,im_kk);
end

end
