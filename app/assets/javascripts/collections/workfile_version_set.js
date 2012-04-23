chorus.collections.WorkfileVersionSet = chorus.collections.Base.extend({
    constructorName: "WorkfileVersionSet",
    urlTemplate:"workspace/{{workspaceId}}/workfile/{{workfileId}}/version",
    model:chorus.models.Workfile,
    comparator:function (model) {
        return -model.get("versionNum");
    }
});