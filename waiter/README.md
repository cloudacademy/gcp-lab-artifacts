### Usage Notes

- Instance (named `instance-name` in the example) startup-script must signal back to the waiter (named `waiter` in the example), for example:

    ```sh
    gcloud beta runtime-config configs variables set \
        success/instance-name instance success --config-name $(ref.waiter.configName)
    ```

- The service account on the instance must be bound to a role with the `runtimeconfig.variables.create` action