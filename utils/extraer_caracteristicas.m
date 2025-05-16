function vector = extraer_caracteristicas(img, numBins)
    R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);
    hsv = rgb2hsv(img);
    H = hsv(:,:,1); V = hsv(:,:,3);

    hH = imhist(H, numBins)';
    hV = imhist(V, numBins)';
    hR = imhist(R, numBins)';
    hG = imhist(G, numBins)';
    hB = imhist(B, numBins)';

    mR = mean(R(:));  sR = std(double(R(:))); skR = skewness(double(R(:))); kuR = kurtosis(double(R(:)));
    mG = mean(G(:));  sG = std(double(G(:))); skG = skewness(double(G(:))); kuG = kurtosis(double(G(:)));
    mB = mean(B(:));  sB = std(double(B(:))); skB = skewness(double(B(:))); kuB = kurtosis(double(B(:)));
    mH = mean(H(:));  sH = std(H(:));         skH = skewness(H(:));         kuH = kurtosis(H(:));
    mV = mean(V(:));  sV = std(V(:));         skV = skewness(V(:));         kuV = kurtosis(V(:));

    percH = max(hH) / sum(hH);
    percV = max(hV) / sum(hV);

    grayImg = rgb2gray(img);
    contrast = std(double(grayImg(:)));
    entGray = entropy(grayImg);

    vector = [hH, hV, hR, hG, hB, ...
              mR, sR, skR, kuR, mG, sG, skG, kuG, mB, sB, skB, kuB, ...
              mH, sH, skH, kuH, mV, sV, skV, kuV, ...
              percH, percV, contrast, entGray];
end