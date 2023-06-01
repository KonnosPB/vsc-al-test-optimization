page 50100 KPBObjectTestMapping
{
    ApplicationArea = All;
    Caption = 'Object/Test Mapping';
    PageType = List;
    SourceTable = KPBObjectTestMapping;
    UsageCategory = Lists;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(ObjectId; Rec.ObjectId)
                {
                    ToolTip = 'Specifies the value of the Object Id field.';
                }
                field(ObjectName; Rec.ObjectName)
                {
                    ToolTip = 'Specifies the value of the Object Name field.';
                }
                field(ObjectType; Rec."ObjectType")
                {
                    ToolTip = 'Specifies the value of the Object Type field.';
                }
                field(TestCodeunitId; Rec.TestCodeunitId)
                {
                    ToolTip = 'Specifies the value of the Test Codeunit Id field.';
                }
                field(TestName; Rec.TestName)
                {
                    ToolTip = 'Specifies the value of the Test Name field.';
                }
            }
        }
    }
}
