chorus.Mixins.InstanceCredentials = {};

chorus.Mixins.InstanceCredentials.model = {
    instanceRequiringCredentials: function() {
        return new chorus.models.DataSource({id: this.serverErrors.model_data.id});
    }
};

chorus.Mixins.InstanceCredentials.page = {
    dependentResourceForbidden: function(resource) {
        var dataSource = resource.instanceRequiringCredentials && resource.instanceRequiringCredentials();

        if (dataSource) {
            var dialog = new chorus.dialogs.InstanceAccount({
                title: t("instances.account.add.title"),
                instance: dataSource,
                reload: true,
                goBack: true
            });
            dialog.launchModal();
        } else {
            this._super("dependentResourceForbidden", arguments);
        }
    }
};
