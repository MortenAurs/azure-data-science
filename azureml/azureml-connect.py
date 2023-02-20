from azureml.core import Workspace

ws = Workspace.from_config()

for compute_name in ws.compute_targets:
    compute = ws.compute_targets[compute_name]
    print(compute.name, ":", compute.type)