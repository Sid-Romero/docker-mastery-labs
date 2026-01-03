# Lab 48: Ansible: Automating Form Submission Approvals with GitOps

![Difficulty: Medium](https://img.shields.io/badge/Difficulty-Medium-yellow) ![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)

> **Auto-generated lab** - Created on 2026-01-03

## Description

This lab demonstrates how to use Ansible to automate a simplified form submission and approval process using GitOps principles. The lab involves creating an Ansible playbook that updates a Git repository based on a simulated form submission, triggering an automated approval workflow.

## Learning Objectives

- Learn how to use Ansible to interact with Git repositories.
- Understand how to automate tasks based on external triggers.
- Implement a basic GitOps workflow using Ansible.
- Use Ansible to manage configuration files.

## Prerequisites

- Ansible installed and configured on a control node.
- Git installed on the control node.
- Access to a Git repository (e.g., GitHub, GitLab, Bitbucket).
- A text editor (e.g., VS Code, Sublime Text).
- Basic understanding of Git and GitOps concepts.

## Lab Steps

### Step 1: Step 1: Set up the Git Repository

1.  Create a new, empty Git repository (e.g., on GitHub). This repository will store the configuration data related to the form submissions.
2.  Clone the repository to your Ansible control node:

    ```bash
    git clone <repository_url> form-submissions
    cd form-submissions
    ```
3.  Create a `config.yml` file in the repository with the following initial content:

    ```yaml
    submissions:
      - id: 1
        name: John Doe
        email: john.doe@example.com
        status: pending
    ```
4. Commit and push the changes to the remote repository.

    ```bash
    git add config.yml
    git commit -m "Initial config file"
    git push origin main
    ```

### Step 2: Step 2: Create the Ansible Playbook

1.  Create a new Ansible playbook file named `form_approval.yml`.
2.  Add the following content to the playbook:

    ```yaml
    ---
    - name: Simulate Form Submission and Approval
      hosts: localhost
      connection: local
      gather_facts: false

      vars:
        submission_id: 2  # Simulated submission ID
        submission_name: 'Jane Smith'
        submission_email: 'jane.smith@example.com'

      tasks:
        - name: Add new submission to config.yml
          blockinfile:
            path: form-submissions/config.yml
            marker: "# {mark} ADD NEW SUBMISSION"
            insertafter: "submissions:"
            block: |
              - id: "{{ submission_id }}"
                name: "{{ submission_name }}"
                email: "{{ submission_email }}"
                status: pending

        - name: Commit changes to Git
          command: git add form-submissions/config.yml
          args:
            chdir: .

        - name: Commit changes to Git
          command: git commit -m "Added new submission"
          args:
            chdir: .

        - name: Push changes to Git
          command: git push origin main
          args:
            chdir: .

        - name: Approve Submission (Simulated)
          debug:
            msg: "Simulating approval process for submission {{ submission_id }}"

        - name: Update Submission Status in config.yml
          replace: 
            path: form-submissions/config.yml
            regexp: 'id: "{{ submission_id }}"\n.*status: pending'
            replace: 'id: "{{ submission_id }}"\n                name: "{{ submission_name }}"\n                email: "{{ submission_email }}"\n                status: approved'

        - name: Commit changes to Git
          command: git add form-submissions/config.yml
          args:
            chdir: .

        - name: Commit changes to Git
          command: git commit -m "Approved submission {{ submission_id }}"
          args:
            chdir: .

        - name: Push changes to Git
          command: git push origin main
          args:
            chdir: .
    ```

### Step 3: Step 3: Run the Ansible Playbook

1.  Execute the Ansible playbook:

    ```bash
    ansible-playbook form_approval.yml
    ```
2.  Examine the output to verify that the playbook ran successfully.  Pay attention to any errors related to git commands.
3.  Check the Git repository to see the updated `config.yml` file with the new submission and the status change to 'approved'.

### Step 4: Step 4: Verify the Results

1.  Inspect the `config.yml` file in your local `form-submissions` directory. It should now contain the new submission and the first submission should be approved. 
2.  Verify that the changes have been pushed to the remote Git repository by checking the repository's commit history and the contents of the `config.yml` file.
3. Consider adding a `pull` step at the beginning of the playbook to ensure you have the latest version of the configuration. This is crucial in a real-world GitOps scenario.


<details>
<summary> Hints (click to expand)</summary>

1. Ensure that you have the correct Git repository URL.
2. Verify that your Ansible control node has the necessary permissions to access the Git repository.
3. Check the `chdir` argument in the `command` module to ensure that the Git commands are executed in the correct directory.
4. Use the `debug` module to print variables and check the state of your playbook.
5. The `replace` module is sensitive to whitespace. Ensure your regex matches the exact whitespace in the `config.yml` file.

</details>


<details>
<summary>✅ Solution Notes (spoiler)</summary>

The solution involves creating an Ansible playbook that interacts with a Git repository to simulate a form submission and approval process. The playbook adds a new submission to a configuration file, commits the changes, and pushes them to the repository. It then simulates an approval process by updating the submission status in the configuration file and pushing the changes again.  The `blockinfile` and `replace` modules are key to manipulating the `config.yml` file.  Error handling and authentication with the Git repository are important considerations for a production environment.

</details>


---

## Notes

- **Difficulty:** Medium
- **Estimated time:** 45-75 minutes
- **Technology:** Ansible

##  Cleanup

Don't forget to clean up resources after completing the lab:

```bash
# Example cleanup commands (adjust based on lab content)
docker system prune -f
# or
kubectl delete -f .
# or
helm uninstall <release-name>
```

---

*This lab was auto-generated by the [Lab Generator Bot](../.github/workflows/generate-lab.yml)*
