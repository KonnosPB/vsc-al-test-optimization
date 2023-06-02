pageextension 50101 KPBALTestTool extends "AL Test Tool"
{
    actions
    {
        addlast(processing)
        {
            group(KPBTestSuggestion)
            {
                Caption = 'Test Suggestion';

                action(KPBRebuildObjectTestMapping)
                {
                    ApplicationArea = All;
                    Caption = 'Build Object/Test Mapping';
                    ToolTip = 'Creates a test suite and automatically adds all test code units in the filter. Executes the tests and logs via code coverage which objects have been "touched". The results are transferred to the object/test mapping table.';
                    Image = Calculate;
                    Visible = true;

                    trigger OnAction()
                    var
                        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
                        KPBCreateObjMapTestSuiteDialog: Page KPBCreateObjectTestMappingDlg;
                        TestSuite: Code[10];
                        TestCodeunitFilter: Text;
                    begin
                        KPBCreateObjMapTestSuiteDialog.LookupMode := true;
                        KPBCreateObjMapTestSuiteDialog.SetALTestSuiteCode(Rec."Test Suite");
                        if KPBCreateObjMapTestSuiteDialog.RunModal() <> Action::LookupOK then
                            exit;

                        TestSuite := KPBCreateObjMapTestSuiteDialog.GetALTestSuiteCode();
                        TestCodeunitFilter := KPBCreateObjMapTestSuiteDialog.GetTestCodeunitFilter();
                        KPBTestSuggestionService.BuildObjectTestMappingTestSuite(TestSuite, TestCodeunitFilter);
                    end;
                }
                action(KPBSuggestTestsByGitDiff)
                {
                    ApplicationArea = All;
                    Caption = 'Create proposal';
                    ToolTip = 'Opens a dialog where the branch must be entered and a Git diff file can be uploaded. A TestSuite is then created with the branch name and the test is automatically added. Before this, "Build Test/Object Mapping" should be executed.';
                    Image = Calculate;
                    Visible = true;

                    trigger OnAction()
                    var
                        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
                        KPBUploadTestSuiteFileDialog: Page KPBUploadGitDiffFileDialog;
                        TestSuite: Code[10];
                    begin
                        KPBUploadTestSuiteFileDialog.LookupMode := true;
                        KPBUploadTestSuiteFileDialog.SetALTestSuiteCode(Rec."Test Suite");
                        if KPBUploadTestSuiteFileDialog.RunModal() <> Action::LookupOK then
                            exit;

                        TestSuite := KPBUploadTestSuiteFileDialog.GetALTestSuiteCode();
                        KPBTestSuggestionService.MakeSuggestionByGitDiff(TestSuite, KPBUploadTestSuiteFileDialog.GetUploadedText());
                        if TestSuite <> Rec."Test Suite" then begin
                            Rec.SetRange("Test Suite", TestSuite);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action(KPBObjectTestMappingOverView)
                {
                    ApplicationArea = All;
                    Caption = 'Object/Test Mapping Overview';
                    Image = List;
                    Visible = true;
                    ToolTip = 'Shows the created test/object mapping table';
                    RunObject = page KPBObjectTestMapping;
                }
                action(KPBObjectTestMappingDownload)
                {
                    ApplicationArea = All;
                    Caption = 'Download Object/Test Mapping Json';
                    Image = List;
                    Visible = true;
                    ToolTip = 'Opens a dialog where you can define which objects should be included. If no filter is set, all objects of the Test Suite are used.';
                    RunObject = page KPBObjectTestMapping;

                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
                        FileBlob: Codeunit "Temp Blob";
                        KPBDownloadObjMapTestSuiteDlg: Page KPBDownloadObjectTestMapDlg;
                        FileOutStream: OutStream;
                        JsonResult: Text;
                    begin
                        KPBDownloadObjMapTestSuiteDlg.LookupMode := true;
                        if KPBDownloadObjMapTestSuiteDlg.RunModal() <> Action::LookupOK then
                            exit;
                        JsonResult := KPBTestSuggestionService.ConvertObjectTestMappingToJson(KPBDownloadObjMapTestSuiteDlg.GetTargetFilter());
                        FileBlob.CreateOutStream(FileOutStream);
                        FileOutStream.Write(JsonResult);
                        FileMgt.BLOBExport(FileBlob, Rec."Test Suite" + '.json', true)
                    end;
                }
                action(KPBObjectTestMappingUpload)
                {
                    ApplicationArea = All;
                    Caption = 'Upload Object/Test Mapping Json';
                    Image = List;
                    Visible = true;
                    ToolTip = 'Opens a file dialog where you can upload the object/test mapping file. An object mapping table will be created.';
                    RunObject = page KPBObjectTestMapping;

                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
                        FileBlob: Codeunit "Temp Blob";
                        FileInStream: InStream;
                        JsonText: Text;
                    begin
                        if FileMgt.BLOBImport(FileBlob, '*.json') = '' then
                            exit;

                        FileBlob.CreateInStream(FileInStream);
                        FileInStream.Read(JsonText);
                        KPBTestSuggestionService.ConvertJsonToObjectTestMapping(JsonText);
                    end;
                }
            }
        }
        addfirst(Category_Process)
        {
            group(KPBTestSuggestion_Promoted)
            {
                Caption = 'Test Vorschlag';

                actionref(KPBRebuildTestMapping_Promoted; KPBRebuildObjectTestMapping)
                {
                }
                actionref(KPBSuggestTestsByGitDiff_Promoted; KPBSuggestTestsByGitDiff)
                {
                }
                group(KPBObjectTestMappingGrp)
                {
                    ShowAs = SplitButton;
                    Caption = 'Object/Test Mapping';
                    actionref(KPBObjectTestMappingOverView_Promoted; KPBObjectTestMappingOverView)
                    {
                    }
                    actionref(KPBObjectTestMappingOverDownload_Promoted; KPBObjectTestMappingDownload)
                    {
                    }
                    actionref(KPBObjectTestMappingUpload_Promoted; KPBObjectTestMappingUpload)
                    {
                    }
                }
            }
        }
    }
}
