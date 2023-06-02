codeunit 50101 KPBTestSuggestionWebservice
{
    procedure BuildObjectTestMapping(TestSuite: Code[10]; TestCodeunitFilter: Text)
    var
        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
    begin
        KPBTestSuggestionService.BuildObjectTestMappingTestSuite(TestSuite, TestCodeunitFilter);
    end;

    procedure GetObjectTestMapping(ObjectFilter: Text): Text
    var
        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
        Result: Text;
    begin
        Result := KPBTestSuggestionService.ConvertObjectTestMappingToJson(ObjectFilter);
        exit(Result);
    end;

    procedure CreateObjectTextMapping(ObjectTestMappingJson: Text)
    var
        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
    begin
        KPBTestSuggestionService.ConvertJsonToObjectTestMapping(ObjectTestMappingJson);
    end;

    procedure CreateSuggestionTestSuite(Branch: Text; GitDiff: Text)
    var
        KPBTestSuggestionService: Codeunit KPBTestSuggestionService;
    begin
        KPBTestSuggestionService.MakeSuggestionByGitDiff(Branch, GitDiff);
    end;
}
