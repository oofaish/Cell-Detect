function [ gtCells ] = abcGroundTurthCellsFromMaskCells( maskCells )
%abcNucleiGroundTruth conver the mask to centroid values
%   convert the mask given by the challenge to the centroid that
%   Carlos's code needs

rpCentroids  = cellfun( @( x ) regionprops( x, 'Centroid' ), maskCells, 'UniformOutput', false )';

%FIXME vectorize this f

gtCells = rpCentroids;
i = 0;
for imageCentroids=rpCentroids
    i = i + 1;
    matlabSucks1 = arrayfun( @( x ) x.Centroid, imageCentroids{1}, 'UniformOutput', false );
    matlabSucks2 = zeros( length( matlabSucks1 ), 2 );
    for j=1:length( matlabSucks1 )
        matlabSucks2(j, :) = arrayfun( @round, matlabSucks1{ j } );
    end
    
    gtCells{ i } =   matlabSucks2;
end

end

