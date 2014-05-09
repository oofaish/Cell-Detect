%imagesc( train_Nuclei{1} );
%imshow( ISBI_Train{1} );

actuallyRun = 1;

if( 0 )
    folder      = 'Train45/';
    load( [ folder 'isbi_train.mat' ] );
    load( [ folder 'isbi_train_GT.mat' ] );
    gtCells = abcGroundTruthCellsFromMaskCells( train_Nuclei );
    images  = ISBI_Train;
else
    folder      = 'Test90/';
    load( [ folder 'isbi_test90.mat' ] );
    load( [ folder 'isbi_test90_GT.mat' ] );
    gtCells = abcGroundTruthCellsFromMaskCells( test_Nuclei );
    images  = ISBI_Test90;
end
    
%now save them in the format carlos wants to make him happy
fileNamePre = 'ISBI_image_';
fileFormat  = 'pgm';

if( actuallyRun )
    for i=1:numel( gtCells )
        fileName = [ folder fileNamePre sprintf( '%03d', i ) ];
        gt = gtCells{ i };
        save( fileName, 'gt' );
    end
end

%now save the images
if( actuallyRun )
    for i=1:numel( images )
        fileName = [ folder fileNamePre sprintf( '%03d', i ) '.' fileFormat ];
        imwrite( images{ i }, fileName );
    end
end


clear ISBI_Train train_Nuclei
