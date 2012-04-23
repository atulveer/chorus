chorus.pages.InstanceIndexPage = chorus.pages.Base.extend({
    crumbs:[
        { label:t("breadcrumbs.home"), url:"#/" },
        { label:t("breadcrumbs.instances") }
    ],
    helpId: "instances",

    setup:function () {
        this.collection = new chorus.collections.InstanceSet();
        this.collection.fetchAll();
        this.dependOn(this.collection, this.setPreselection);

        this.mainContent = new chorus.views.MainContentView({
            contentHeader:new chorus.views.StaticTemplate("default_content_header", {title:t("instances.title_plural")}),
            contentDetails:new chorus.views.InstanceIndexContentDetails({collection:this.collection}),
            content:new chorus.views.InstanceList({collection:this.collection})
        });

        this.sidebar = new chorus.views.InstanceListSidebar();

        chorus.PageEvents.subscribe("instance:selected", this.setModel, this);
    },

    setPreselection: function() {
        if (this.pageOptions && this.pageOptions.selectId) {
            this.mainContent.content.selectedInstanceId = this.pageOptions.selectId;
            this.mainContent.content.render();
        }
    },

    setModel:function (instance) {
        this.model = instance;
    }
});