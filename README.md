Overview
AdminTool is a powerful Visualforce-based utility designed for Salesforce administrators to perform bulk operations on Salesforce objects efficiently. This tool simplifies common administrative tasks, reducing the need for custom code or separate data loader operations.

<a href="https://githubsfdeploy.herokuapp.com?owner=kevkol&amp;repo=AdminTool/">
  <img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png" style="max-width:100%;">
</a>

Deploy Admin Tool Code


Features
1. Delete sObject Records

Select any sObject
Specify a WHERE clause to target specific records
Preview the deletion query before execution
Perform bulk deletions with configurable batch sizes

2. Update sObject Records

Choose any sObject for updates
Dynamically select fields based on the chosen sObject
Set new values for selected fields
Use a WHERE clause to target specific records
Configure batch sizes and "All or None" behavior
Preview update queries before execution

3. Copy Field Values

Select source and target fields within the same sObject
Use a WHERE clause to specify which records to update
Set batch sizes for efficient processing

Installation

Deploy the following components to your Salesforce org:

AdminToolCtr.cls (Apex Controller)
AdminToolCtrTest.cls (Test Class)
AdminTool.page (Visualforce Page)


Assign necessary permissions to users who will access the AdminTool.

Usage

Navigate to the AdminTool Visualforce page in your Salesforce org.
Select the operation you want to perform (Delete, Update, or Copy Field).
Choose the sObject you want to work with.
For Update and Copy operations, select the relevant fields.
Specify a WHERE clause if needed to target specific records.
Set your batch size and other options as required.
Use the "Preview Query" button to review your operation before execution.
Click the respective operation button (Delete, Update, or Copy) to execute.

Best Practices

Always use the "Preview Query" feature before executing operations to ensure accuracy.
Start with smaller batch sizes and increase as needed for performance.
Use specific WHERE clauses to target the exact records you intend to modify.
Regularly review and update user permissions for the AdminTool.

Contributing
We welcome contributions to the AdminTool! Please read our CONTRIBUTING.md for details on how to submit pull requests, report issues, or request features.
License
This project is licensed under the MIT License - see the LICENSE.md file for details.
Support
For support, please open an issue on the GitHub repository or contact the maintainers directly.