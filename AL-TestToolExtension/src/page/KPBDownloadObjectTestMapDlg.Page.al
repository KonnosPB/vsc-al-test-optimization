page 50103 KPBDownloadObjectTestMapDlg
{
    ApplicationArea = All;
    Caption = 'Download Object/Mapping Json';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(TargetFilter; TargetFilter)
                {
                    Caption = 'Filter';
                    ToolTip = 'Restricts the number of objects to keep the object mapping as small as possible. Typically enter a prefix / suffic of your solution.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        TargetFilter := 'KVS*';
    end;

    internal procedure GetTargetFilter(): Text
    begin
        exit(TargetFilter);
    end;

    var
        TargetFilter: Text;
}
