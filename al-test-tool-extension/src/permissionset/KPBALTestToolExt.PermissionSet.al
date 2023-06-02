permissionset 50100 "KPBALTestToolExt"
{
    Caption = 'KPB AL Test Tool';
    Assignable = true;
    Permissions = tabledata KPBObjectTestMapping = RIMD,
        table KPBObjectTestMapping = X,
        codeunit KPBTestSuggestionService = X,
        codeunit KPBTestSuggestionWebservice = X,
        page KPBCreateObjectTestMappingDlg = X,
        page KPBDownloadObjectTestMapDlg = X,
        page KPBObjectTestMapping = X,
        page KPBUploadGitDiffFileDialog = X;
}