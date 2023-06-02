table 50100 KPBObjectTestMapping
{
    Caption = 'KPB Object Test Mapping';
    DataClassification = SystemMetadata;
    LookupPageId = KPBObjectTestMapping;
    DrillDownPageId = KPBObjectTestMapping;

    fields
    {
        field(1; EntryNo; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(3; ObjectType; Option)
        {
            Caption = 'Object Type';
            DataClassification = SystemMetadata;
            OptionMembers = "TableData","Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query","System",FieldNumber,,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension","PermissionSet","PermissionSetExtension","ReportExtension";
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension,PermissionSet,PermissionSetExtension,ReportExtension';
        }
        field(4; ObjectId; Integer)
        {
            Caption = 'Object Id';
            DataClassification = SystemMetadata;
        }
        field(5; ObjectName; Text[30])
        {
            Caption = 'Object Name';
            DataClassification = SystemMetadata;
        }
        field(6; TestCodeunitId; Integer)
        {
            Caption = 'Test Codeunit Id';
            DataClassification = SystemMetadata;
        }
        field(8; TestName; Text[128])
        {
            Caption = 'Test Name';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
        key(SK1; ObjectType, ObjectId, TestCodeunitId)
        {
        }
        key(SK2; TestCodeunitId)
        {
        }
    }
}
