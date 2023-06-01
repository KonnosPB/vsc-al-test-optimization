page 50101 KPBUploadGitDiffFileDialog
{
    ApplicationArea = All;
    Caption = 'Upload Git Diff File';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(ALTestSuiteCode; ALTestSuiteCode)
                {
                    Caption = 'Branch';
                    ToolTip = 'The branch name which is converted to the test suite code later';

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                        FileBlob: Codeunit "Temp Blob";
                        FileInstream: InStream;
                        GitDiffPart: Text;
                    begin
                        Clear(UploadedText);
                        if FileManagement.BLOBImport(FileBlob, 'Git Diff') = '' then
                            exit;
                        FileBlob.CreateInStream(FileInstream);
                        while not FileInstream.EOS do begin
                            FileInstream.Read(GitDiffPart);
                            UploadedText += GitDiffPart;
                        end;
                    end;
                }
            }
        }
    }

    internal procedure SetALTestSuiteCode(Code: Code[10])
    begin
        ALTestSuiteCode := Code;
    end;

    internal procedure GetALTestSuiteCode(): Code[10]
    begin
        exit(ALTestSuiteCode);
    end;

    internal procedure GetUploadedText(): Text
    begin
        exit(UploadedText);
    end;

    var
        ALTestSuiteCode: Code[10];
        UploadedText: Text;
}
