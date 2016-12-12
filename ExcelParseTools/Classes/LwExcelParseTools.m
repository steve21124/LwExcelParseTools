//
//  XmlParseTools.m
//  Pods
//
//  Created by guakeliao on 16/8/8.
//
//

#import "LwExcelParseTools.h"
#import "BRASheet.h"
@implementation LwExcelParseTools

+ (NSMutableArray *)excelParseForResource:(NSString *)filePath
{
    NSMutableArray *totalArray = [NSMutableArray array];
    NSString *type = [[[filePath lastPathComponent] componentsSeparatedByString:@"."] lastObject];
    if ([[type lowercaseString] isEqualToString:@"xls"])
    {
        DHxlsReader *reader = [DHxlsReader xlsReaderWithPath:filePath];
        assert(reader);
        //每个sheet
        for (uint32_t i = 0; i <= [reader numberOfSheets]; i++)
        {
            NSMutableArray *sheetArray = [NSMutableArray array];
            //行 row
            for (uint16_t j = 1; j < [reader numberOfRowsInSheet:i]; j++)
            {
                NSMutableArray *rowArr = [NSMutableArray array];
                //列 col
                for (uint16_t k = 1; k < [reader numberOfColsInSheet:i]; k++)
                {
                    DHcell *cell = [reader cellInWorkSheetIndex:i row:j col:k];
                    [rowArr addObject:cell.str ?: @""];
                }
                [sheetArray addObject:rowArr];
            }
            [totalArray addObject:sheetArray];
        }
    }
    else if ([[type lowercaseString] isEqualToString:@"xlsx"])
    {
        BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:filePath];
        for (BRAWorksheet *worksheet in spreadsheet.workbook.worksheets)
        {
            NSMutableArray *sheetArray = [NSMutableArray array];
            for (uint32_t i = 1; i <= worksheet.dimension.bottomRowIndex; i++)
            {
                NSMutableArray *rowArr = [NSMutableArray array];
                for (uint32_t j = worksheet.dimension.leffColumnIndex;
                     j <= worksheet.dimension.rightColumnIndex; j++)
                {
                    BRACell *cell = [worksheet
                        cellForCellReference:[NSString stringWithFormat:@"%c%d", (j + 64), i]];
                    if (cell)
                    {
                        [rowArr addObject:[[cell attributedStringValue] string]];
                    }
                    else
                    {
                        [rowArr addObject:@""];
                    }
                }
                [sheetArray addObject:rowArr];
            }
            [totalArray addObject:sheetArray];
        }
    }
    return totalArray;
}

+ (NSMutableArray *)excelParseForResourceWithHeader:(NSString *)filePath
{
    NSMutableArray *totalArray = [NSMutableArray array];
    NSString *filename = [filePath lastPathComponent];
    NSString *type = [[[filePath lastPathComponent] componentsSeparatedByString:@"."] lastObject];
    if ([[type lowercaseString] isEqualToString:@"xls"])
    {
        DHxlsReader *reader = [DHxlsReader xlsReaderWithPath:filePath];
        assert(reader);
        NSMutableArray *headerArray = [NSMutableArray array];
        for (uint32_t i = 0; i < [reader numberOfSheets]; i++)
        {
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
            [headerDict setObject:[reader sheetNameAtIndex:i] forKey:@"name"];
            [headerDict setObject:filename forKey:@"excel_cache_filename"];
            [headerArray addObject:headerDict];
        }
         [totalArray addObject:headerArray];
        //每个sheet
        for (uint32_t i = 0; i < [reader numberOfSheets]; i++)
        {
            NSMutableArray *sheetArray = [NSMutableArray array];
            //行 row
            for (uint16_t j = 1; j < [reader numberOfRowsInSheet:i]; j++)
            {
                NSMutableArray *rowArr = [NSMutableArray array];
                //列 col
                for (uint16_t k = 1; k < [reader numberOfColsInSheet:i]; k++)
                {
                    DHcell *cell = [reader cellInWorkSheetIndex:i row:j col:k];
                    [rowArr addObject:cell.str ?: @""];
                }
                [sheetArray addObject:rowArr];
            }
            [totalArray addObject:sheetArray];
        }
    }
    else if ([[type lowercaseString] isEqualToString:@"xlsx"])
    {
        BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:filePath];
        NSMutableArray *relationShips = spreadsheet.relationships.relationshipsArray;
        BRAOfficeDocument *officeDocument = relationShips[0];
        NSMutableArray *sheets = officeDocument.sheets;
        
        NSMutableArray *headerArray = [NSMutableArray array];
        for (BRASheet *sheet in sheets) {
            
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
            [headerDict setObject:sheet.name forKey:@"name"];
            [headerArray addObject:headerDict];;
        }
        [totalArray addObject:headerArray];
        
        for (BRAWorksheet *worksheet in spreadsheet.workbook.worksheets)
        {
            NSMutableArray *sheetArray = [NSMutableArray array];
            for (uint32_t i = 1; i <= worksheet.dimension.bottomRowIndex; i++)
            {
                NSMutableArray *rowArr = [NSMutableArray array];
                for (uint32_t j = worksheet.dimension.leffColumnIndex;
                     j <= worksheet.dimension.rightColumnIndex; j++)
                {
                    BRACell *cell = [worksheet
                                     cellForCellReference:[NSString stringWithFormat:@"%c%d", (j + 64), i]];
                    if (cell)
                    {
                        [rowArr addObject:[[cell attributedStringValue] string]];
                    }
                    else
                    {
                        [rowArr addObject:@""];
                    }
                }
                [sheetArray addObject:rowArr];
            }
            [totalArray addObject:sheetArray];
        }
    }
    return totalArray;
}

@end
