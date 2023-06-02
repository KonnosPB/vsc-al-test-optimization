page 50102 KPBCreateObjectTestMappingDlg
{
    ApplicationArea = All;
    Caption = 'Create Object/Mapping';
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
                    ToolTip = 'Specifies the branch name which is later converted to the al test suite code';
                }
                field(TestCodeunitFilter; TestCodeunitFilter)
                {
                    Caption = 'Filter';
                    ToolTip = 'Sets a filter on the test codeunit. Typically enter the prefix or suffix of your solution here.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        TestCodeunitFilter := '<Prefix>*';
        ALTestSuiteCode := 'OBJMAP';
    end;

    internal procedure SetALTestSuiteCode(Code: Code[10])
    begin
        ALTestSuiteCode := Code;
    end;

    internal procedure GetALTestSuiteCode(): Code[10]
    begin
        exit(ALTestSuiteCode);
    end;

    internal procedure GetTestCodeunitFilter(): Text
    begin
        exit(TestCodeunitFilter);
    end;

    var
        ALTestSuiteCode: Code[10];
        TestCodeunitFilter: Text;
}
