codeunit 50100 KPBTestSuggestionService
{
    Access = Internal;
    SingleInstance = true;

    internal procedure ConvertObjectTestMappingToJson(ObjectFilter: Text) Result: Text
    var
        KPBObjectTestMapping: Record KPBObjectTestMapping;
        JArray: JsonArray;
        JObject: JsonObject;
        JRoot: JsonObject;
    begin
        KPBObjectTestMapping.Reset();
        if ObjectFilter <> '' then
            KPBObjectTestMapping.SetFilter(ObjectName, ObjectFilter);
        if KPBObjectTestMapping.FindSet(false) then
            repeat
                Clear(JObject);
                JObject.Add('ObjectType', KPBObjectTestMapping.ObjectType);
                JObject.Add('ObjectId', KPBObjectTestMapping.ObjectId);
                JObject.Add('ObjectName', KPBObjectTestMapping.ObjectName);
                JObject.Add('TestCodeunitId', KPBObjectTestMapping.TestCodeunitId);
                JObject.Add('TestName', KPBObjectTestMapping.TestName);
                JArray.Add(JObject);
            until KPBObjectTestMapping.Next() = 0;
        JRoot.Add('ObjectTestMappings', JArray);
        JRoot.WriteTo(Result);
        exit(Result);
    end;

    internal procedure ConvertJsonToObjectTestMapping(JsonObjectTestMapping: Text)
    var
        KPBObjectTestMapping: Record KPBObjectTestMapping;
        LineNo: Integer;
        JArray: JsonArray;
        JObject: JsonObject;
        JRoot: JsonObject;
        JArrToken: JsonToken;
        JToken: JsonToken;
    begin
        JRoot.ReadFrom(JsonObjectTestMapping);
        JRoot.Get('TestSuite', JToken);

        KPBObjectTestMapping.Reset();
        KPBObjectTestMapping.DeleteAll();

        JRoot.Get('ObjectTestMappings', JToken);
        JArray := JToken.AsArray();
        foreach JArrToken in JArray do begin
            JObject := JArrToken.AsObject();
            LineNo += 1;
            KPBObjectTestMapping.Init();
            KPBObjectTestMapping.EntryNo := LineNo;
            JObject.Get('ObjectId', JToken);
            KPBObjectTestMapping.ObjectId := JToken.AsValue().AsInteger();
            JObject.Get('ObjectType', JToken);
            KPBObjectTestMapping.ObjectType := JToken.AsValue().AsInteger();
            JObject.Get('ObjectName', JToken);
            KPBObjectTestMapping.ObjectName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(KPBObjectTestMapping.ObjectName));
            JObject.Get('TestCodeunitId', JToken);
            KPBObjectTestMapping.TestCodeunitId := JToken.AsValue().AsInteger();
            JObject.Get('TestName', JToken);
            KPBObjectTestMapping.TestName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(KPBObjectTestMapping.ObjectName));
            KPBObjectTestMapping.Insert(true);
        end;
    end;

    internal procedure BuildObjectTestMappingTestSuite(ALTestSuiteCode: Code[10]; TestCodeunitFilter: Text)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ALTestSuite: Record "AL Test Suite";
        TestMethodLine: Record "Test Method Line";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        DefaultTestSuiteIsNotAllowedErr: Label 'Please selected an other test suite name. Default is not allowed';
    begin
        if ALTestSuiteCode = 'DEFAULT' then
            Error(DefaultTestSuiteIsNotAllowedErr);

        ALTestSuite := CreateOrUpdateALTestSuite(ALTestSuiteCode);

        TestMethodLine.Reset();
        TestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
        TestMethodLine.DeleteAll(true);

        AllObjWithCaption.Reset();
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Codeunit);
        AllObjWithCaption.SetRange("Object Subtype", 'Test');
        AllObjWithCaption.SetFilter("Object Name", TestCodeunitFilter);
        if AllObjWithCaption.IsEmpty() then
            TrySetObjectIdFilter(AllObjWithCaption, TestCodeunitFilter);
        if AllObjWithCaption.IsEmpty() then
            AllObjWithCaption.SetFilter("Object Caption", TestCodeunitFilter);

        TestSuiteMgt.GetTestMethods(ALTestSuite, AllObjWithCaption);
        BuildObjectTestMappingTestSuite(ALTestSuiteCode);
    end;

    [TryFunction]
    local procedure TrySetObjectIdFilter(var AllObjWithCaption: Record AllObjWithCaption; TestCodeunitFilter: Text)
    begin
        AllObjWithCaption.SetFilter("Object ID", TestCodeunitFilter);
    end;

    internal procedure BuildObjectTestMappingTestSuite(ALTestSuiteCode: Code[10])
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ALTestSuite: Record "AL Test Suite";
        CodeCoverage: Record "Code Coverage";
        KPBObjectTestMapping: Record KPBObjectTestMapping;
        TestMethodLine: Record "Test Method Line";
        CodeCoverageMgt: Codeunit "Code Coverage Mgt.";
        LineNo: Integer;
    begin
        ALTestSuite := CreateOrUpdateALTestSuite(ALTestSuiteCode);

        KPBObjectTestMapping.Reset();
        KPBObjectTestMapping.DeleteAll();

        TestMethodLine.Reset();
        TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::Function);
        TestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
        if TestMethodLine.FindSet(false) then
            repeat
                Codeunit.Run(ALTestSuite."Test Runner Id", TestMethodLine);
                CodeCoverageMgt.Refresh();
                if CodeCoverageMgt.Running() then
                    CodeCoverageMgt.Stop();

                KPBObjectTestMapping.Reset();
                KPBObjectTestMapping.SetRange(TestCodeunitId, TestMethodLine."Test Codeunit");
                CodeCoverage.SetRange("Line Type", CodeCoverage."Line Type"::Object);
                CodeCoverage.SetFilter("Object ID", '..9989|10000..129999|150000..');
                if CodeCoverage.FindSet() then
                    repeat
                        KPBObjectTestMapping.SetRange(ObjectType, CodeCoverage."Object Type");
                        KPBObjectTestMapping.SetRange(ObjectId, CodeCoverage."Object ID");
                        if KPBObjectTestMapping.IsEmpty() then begin
                            AllObjWithCaption.Get(CodeCoverage."Object Type", CodeCoverage."Object ID");
                            LineNo += 1;
                            KPBObjectTestMapping.Init();
                            KPBObjectTestMapping.EntryNo := LineNo;
                            KPBObjectTestMapping.ObjectId := CodeCoverage."Object ID";
                            KPBObjectTestMapping.ObjectType := CodeCoverage."Object Type";
                            KPBObjectTestMapping.ObjectName := AllObjWithCaption."Object Name";
                            KPBObjectTestMapping.TestCodeunitId := TestMethodLine."Test Codeunit";
                            KPBObjectTestMapping.TestName := TestMethodLine.Name;
                            KPBObjectTestMapping.Insert(true);
                        end;
                    until CodeCoverage.Next() = 0;
            until TestMethodLine.Next() = 0;
    end;

    internal procedure MakeSuggestionByGitDiff(Branch: Text; GitDiff: Text) ALTestSuiteCode: Code[10]
    var
        TempRegexGroups: Record Groups temporary;
        TempRegexMatches: Record Matches temporary;
        TempRegexOptions: Record "Regex Options" temporary;
        Regex: Codeunit Regex;
        JArray: JsonArray;
        JObject: JsonObject;
        ObjectIdRegexTxt: Label ' *(?<object_type>\w+) (?<object_id>\d+) *"?(?<object_name>[^"|\n]+)"? *(extends *"?(?<extended_object_name>[^"|\n]+)")?', Locked = true;
    begin
        TempRegexOptions.IgnoreCase := true;
        Regex.Regex(ObjectIdRegexTxt, TempRegexOptions);
        Regex.Match(GitDiff, TempRegexMatches);
        if not TempRegexMatches.Success then
            exit;

        if TempRegexMatches.IsEmpty() then
            exit;

        TempRegexMatches.FindSet();
        repeat
            Clear(TempRegexGroups);
            Clear(JObject);
            TempRegexGroups.DeleteAll();
            Regex.Groups(TempRegexMatches, TempRegexGroups);
            TempRegexGroups.Reset();
            TempRegexGroups.SetRange(Name, 'object_type');
            TempRegexGroups.FindFirst();
            JObject.Add('ObjectType', TempRegexGroups.ReadValue());

            TempRegexGroups.Reset();
            TempRegexGroups.SetRange(Name, 'object_id');
            TempRegexGroups.FindFirst();
            JObject.Add('ObjectId', TempRegexGroups.ReadValue());
            JArray.Add(JObject);

            TempRegexGroups.Reset();
            TempRegexGroups.SetRange(Name, 'extended_object_name');
            if TempRegexGroups.FindFirst() then
                if TempRegexGroups.Success then begin
                    JObject.Add('Extends', TempRegexGroups.ReadValue());
                    JArray.Add(JObject);
                end;
        until TempRegexMatches.Next() = 0;

        ALTestSuiteCode := MakeSuggestion(Branch, JArray);
        exit(ALTestSuiteCode);
    end;

    internal procedure MakeSuggestion(Branch: Text; ObjectIdJson: Text) ALTestSuiteCode: Code[10]
    var
        JArray: JsonArray;
        InvalidJsonErr: Label 'Invalid json. Assuming an something like that [{ "ObjectType": "Page", "ObjectId": "18" }, { "ObjectType": "Page", "ObjectId": "22" } ]. Currently is "%1"', Comment = '%1=Array';
    begin
        if not JArray.ReadFrom(ObjectIdJson) then
            Error(InvalidJsonErr, ObjectIdJson);
        ALTestSuiteCode := MakeSuggestion(Branch, JArray);
        exit(ALTestSuiteCode);
    end;

    internal procedure MakeSuggestion(Branch: Text; JArray: JsonArray) ALTestSuiteCode: Code[10]
    var
        AllObj: Record AllObj;
        ALTestSuite: Record "AL Test Suite";
        KPBObjectTestMapping: Record KPBObjectTestMapping;
        TempTestMethodLine: Record "Test Method Line" temporary;
        TempTestMethodLine2: Record "Test Method Line" temporary;
        TestMethodLine: Record "Test Method Line";
        LineNo: Integer;
        ObjectId: Integer;
        JObject: JsonObject;
        JToken: JsonToken;
        JValueToken: JsonToken;
        ExtendsName: Text;
        ObjectType: Text;
    begin
        ALTestSuiteCode := CopyStr(Branch, 1, MaxStrLen(ALTestSuiteCode));
        if not ALTestSuite.Get(ALTestSuiteCode) then begin
            ALTestSuite.Init();
            ALTestSuite.Name := ALTestSuiteCode;
            ALTestSuite.Insert(true);
        end;

        TestMethodLine.Reset();
        TestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
        TestMethodLine.DeleteAll(true);

        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            JObject.Get('ObjectId', JValueToken);
            ObjectId := JValueToken.AsValue().AsInteger();

            KPBObjectTestMapping.Reset();
            KPBObjectTestMapping.SetRange(ObjectId, ObjectId);

            JObject.Get('ObjectType', JValueToken);
            ObjectType := JValueToken.AsValue().AsText().ToLower();
            case ObjectType of
                'table':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Table);
                'tableextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::TableExtension);
                'codeunit':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Codeunit);
                'report':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Report);
                'reportextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::ReportExtension);
                'xmlport':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::XMLport);
                'page':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Page);
                'pageextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::PageExtension);
                'query':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Query);
                'enum':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Enum);
                'enumextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::EnumExtension);
                'permissionset':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::PermissionSet);
                'permissionsetextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::PermissionSetExtension);
                'profile':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::Profile);
                'profileextension':
                    KPBObjectTestMapping.SetRange(ObjectType, KPBObjectTestMapping.ObjectType::ProfileExtension);
            end;

            if KPBObjectTestMapping.FindSet(false) then
                repeat
                    TempTestMethodLine.Reset();
                    TempTestMethodLine.SetRange("Line Type", TempTestMethodLine."Line Type"::Codeunit);
                    TempTestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
                    TempTestMethodLine.SetRange("Test Codeunit", KPBObjectTestMapping.TestCodeunitId);
                    if TempTestMethodLine.IsEmpty() then begin
                        LineNo += 100;
                        TempTestMethodLine.Init();
                        TempTestMethodLine."Test Suite" := ALTestSuiteCode;
                        TempTestMethodLine."Line No." := LineNo;
                        TempTestMethodLine."Line Type" := TestMethodLine."Line Type"::Codeunit;
                        TempTestMethodLine."Test Codeunit" := KPBObjectTestMapping.TestCodeunitId;
                        TempTestMethodLine.Insert(true);
                    end;
                    TempTestMethodLine2.Reset();
                    TempTestMethodLine2.SetRange("Line Type", TempTestMethodLine."Line Type"::Function);
                    TempTestMethodLine2.SetRange("Test Suite", ALTestSuiteCode);
                    TempTestMethodLine2.SetRange("Test Codeunit", KPBObjectTestMapping.TestCodeunitId);
                    TempTestMethodLine2.SetRange(Name, KPBObjectTestMapping.TestName);
                    if TempTestMethodLine2.IsEmpty() then begin
                        LineNo += 100;
                        TempTestMethodLine2.Init();
                        TempTestMethodLine2."Test Suite" := ALTestSuiteCode;
                        TempTestMethodLine2."Line No." := LineNo;
                        TempTestMethodLine2."Line Type" := TestMethodLine."Line Type"::Function;
                        TempTestMethodLine2."Test Codeunit" := KPBObjectTestMapping.TestCodeunitId;
                        TempTestMethodLine2.Name := KPBObjectTestMapping.TestName;
                        TempTestMethodLine2.Function := KPBObjectTestMapping.TestName;
                        TempTestMethodLine2.Insert();
                    end;
                until KPBObjectTestMapping.Next() = 0;

            if JObject.Contains('Extends') then begin
                JObject.Get('Extends', JValueToken);
                ExtendsName := JValueToken.AsValue().AsText();

                AllObj.Reset();
                AllObj.SetRange("Object Name", ExtendsName);
                case ObjectType of
                    'tableextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
                    'reportextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Report);
                    'pageextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Page);
                    'enumextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Enum);
                    'permissionsetextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::PermissionSet);
                    'profileextension':
                        AllObj.SetRange("Object Type", AllObj."Object Type"::Profile);
                end;

                if AllObj.FindFirst() then begin
                    KPBObjectTestMapping.Reset();
                    KPBObjectTestMapping.SetRange(ObjectId, AllObj."Object ID");
                    KPBObjectTestMapping.SetRange(ObjectType, AllObj."Object Type");
                    if KPBObjectTestMapping.FindSet(false) then
                        repeat
                            TempTestMethodLine.Reset();
                            TempTestMethodLine.SetRange("Line Type", TempTestMethodLine."Line Type"::Codeunit);
                            TempTestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
                            TempTestMethodLine.SetRange("Test Codeunit", KPBObjectTestMapping.TestCodeunitId);
                            if TempTestMethodLine.IsEmpty() then begin
                                LineNo += 100;
                                TempTestMethodLine.Init();
                                TempTestMethodLine."Test Suite" := ALTestSuiteCode;
                                TempTestMethodLine."Line No." := LineNo;
                                TempTestMethodLine."Line Type" := TestMethodLine."Line Type"::Codeunit;
                                TempTestMethodLine."Test Codeunit" := KPBObjectTestMapping.TestCodeunitId;
                                TempTestMethodLine.Insert(true);
                            end;
                            TempTestMethodLine2.Reset();
                            TempTestMethodLine2.SetRange("Line Type", TempTestMethodLine."Line Type"::Function);
                            TempTestMethodLine2.SetRange("Test Suite", ALTestSuiteCode);
                            TempTestMethodLine2.SetRange("Test Codeunit", KPBObjectTestMapping.TestCodeunitId);
                            TempTestMethodLine2.SetRange(Name, KPBObjectTestMapping.TestName);
                            if TempTestMethodLine2.IsEmpty() then begin
                                LineNo += 100;
                                TempTestMethodLine2.Init();
                                TempTestMethodLine2."Test Suite" := ALTestSuiteCode;
                                TempTestMethodLine2."Line No." := LineNo;
                                TempTestMethodLine2."Line Type" := TestMethodLine."Line Type"::Function;
                                TempTestMethodLine2."Test Codeunit" := KPBObjectTestMapping.TestCodeunitId;
                                TempTestMethodLine2.Name := KPBObjectTestMapping.TestName;
                                TempTestMethodLine2.Function := KPBObjectTestMapping.TestName;
                                TempTestMethodLine2.Insert();
                            end;
                        until KPBObjectTestMapping.Next() = 0;
                end;
            end;
        end;

        LineNo := 0;
        TempTestMethodLine.Reset();
        TempTestMethodLine.SetRange("Test Suite", ALTestSuiteCode);
        TempTestMethodLine.SetRange("Line Type", TempTestMethodLine."Line Type"::Codeunit);
        if TempTestMethodLine.FindSet(false) then
            repeat
                TempTestMethodLine2.Reset();
                TempTestMethodLine2.SetRange("Test Suite", ALTestSuiteCode);
                TempTestMethodLine2.SetRange("Line Type", TempTestMethodLine."Line Type"::Function);
                TempTestMethodLine2.SetRange("Test Codeunit", TempTestMethodLine."Test Codeunit");
                if not TempTestMethodLine2.IsEmpty() then begin
                    LineNo += 10000;
                    TestMethodLine.Init();
                    TestMethodLine."Test Suite" := TempTestMethodLine."Test Suite";
                    TestMethodLine."Line No." := LineNo;
                    TestMethodLine.Validate("Line Type", TempTestMethodLine."Line Type"::Codeunit);
                    TestMethodLine.Validate("Test Codeunit", TempTestMethodLine."Test Codeunit");
                    TestMethodLine.Insert(true);
                end;
                if TempTestMethodLine2.FindSet(false) then
                    repeat
                        LineNo += 10000;
                        TestMethodLine.Init();
                        TestMethodLine."Test Suite" := TempTestMethodLine2."Test Suite";
                        TestMethodLine."Line No." := LineNo;
                        TestMethodLine.Validate("Line Type", TempTestMethodLine2."Line Type"::Function);
                        TestMethodLine.Validate("Test Codeunit", TempTestMethodLine2."Test Codeunit");
                        TestMethodLine.Validate(Function, TempTestMethodLine2.Name);
                        TestMethodLine.Validate(Name, TempTestMethodLine2.Name);
                        TestMethodLine.Insert(true);
                    until TempTestMethodLine2.Next() = 0;
            until TempTestMethodLine.Next() = 0;
    end;

    local procedure CreateOrUpdateALTestSuite(ALTestSuiteCode: Code[10]) ALTestSuite: Record "AL Test Suite"
    begin
        if not ALTestSuite.Get(ALTestSuiteCode) then begin
            ALTestSuite.Init();
            ALTestSuite.Name := ALTestSuiteCode;
            ALTestSuite."Test Runner Id" := Codeunit::"Test Runner - Isol. Codeunit";
            ALTestSuite."CC Track All Sessions" := false;
            ALTestSuite."CC Tracking Type" := ALTestSuite."CC Tracking Type"::"Per Test";
            ALTestSuite.Insert(true);
        end else
            if ALTestSuite."CC Tracking Type" <> ALTestSuite."CC Tracking Type"::"Per Test" then begin
                ALTestSuite."CC Track All Sessions" := true;
                ALTestSuite."CC Tracking Type" := ALTestSuite."CC Tracking Type"::"Per Test";
                ALTestSuite.Modify();
            end;
        exit(ALTestSuite);
    end;
}
