import { Controller } from "stimulus";

export default class extends Controller {
    connect() {
        $("#promote-member-modal").on("show.bs.modal", (e) => {
            const groupmember = $(e.relatedTarget).data("currentgroupmember");
            $(e.currentTarget)
                .find("#groups-member-promote-button")
                .parent()
                .attr("action", `/group_members/${groupmember.toString()}`);
        });
        $("#demote-member-modal").on("show.bs.modal", (e) => {
            const groupmember = $(e.relatedTarget).data("currentgroupmember");
            $(e.currentTarget)
                .find("#groups-member-demote-button")
                .parent()
                .attr("action", `/group_members/${groupmember.toString()}`);
        });
    }

    toggleButtonBasedOnEmails(emailSelector, buttonSelector) {
        if ($(emailSelector).select2("data").length > 0) {
            $(buttonSelector).attr("disabled", false);
        } else {
            $(buttonSelector).attr("disabled", true);
        }
    }

    setupCSVUpload(
        csvUploadContainerSelector = ".csv-upload-container",
        emailInputSelector = "#group_member_emails",
        addButtonSelector = "#add-members-button"
    ) {
        this.csvSelector = csvUploadContainerSelector;
        this.emailInputSelector = emailInputSelector;
        this.addButtonSelector = addButtonSelector;
        document.querySelector(
            this.csvSelector
        ).innerHTML = `<input type="file" id="csv-file-upload" accept=".csv" style="display:none">
            <div id="csv-file-name" class="my-1 csv-file-info"></div>
            <div class="csv-dropzone">
              <i class="fas fa-file-csv"></i> Drag a CSV file or Select
            </div>`;

        // Set up file input and dropzone
        const fileInput = document.getElementById("csv-file-upload");
        const fileInfo = document.getElementById("csv-file-name");
        const dropzone = document.querySelector(".csv-dropzone");
        const addButton = document.querySelector(addButtonSelector);
        let messageTimeout = null;

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        function showMessage(message, isError = false) {
            // Clear any existing timeout
            if (messageTimeout) {
                clearTimeout(messageTimeout);
            }

            // Remove csv-msg-fade-out class if it exists
            fileInfo.classList.remove("csv-msg-fade-out");

            // Set the message
            fileInfo.innerHTML = isError
                ? `<span class="csv-error">${message}</span>`
                : `<span class="csv-success">${message}</span>`;

            // Set timeout to fade out the message after 11 seconds
            messageTimeout = setTimeout(() => {
                fileInfo.classList.add("csv-msg-fade-out");

                // Clear the message after fade completes
                setTimeout(() => {
                    if (fileInfo.classList.contains("csv-msg-fade-out")) {
                        fileInfo.innerHTML = "";
                        fileInfo.classList.remove("csv-msg-fade-out");
                    }
                }, 500);
            }, 11000);
        }

        function handleFile(file) {
            if (!file) return;

            if (file.type !== "text/csv" && !file.name.endsWith(".csv")) {
                showMessage("Please upload a CSV file", true);
                fileInput.value = "";
                return;
            }

            fileInfo.innerHTML = "<span>Processing...</span>";

            const reader = new FileReader();
            reader.onload = function (event) {
                try {
                    const csvData = event.target.result;
                    const lines = csvData.split(/\r\n|\n/);
                    const emails = [];

                    // Extract emails from all columns
                    for (let i = 0; i < lines.length; i++) {
                        if (lines[i].trim()) {
                            const columns = lines[i].split(",");
                            columns.forEach((column) => {
                                const value = column.trim();
                                if (
                                    value &&
                                    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
                                ) {
                                    emails.push(value);
                                }
                            });
                        }
                    }

                    if (emails.length > 0) {
                        // Get the Select2 element and add emails
                        const emailSelect = $(emailInputSelector);

                        emails.forEach((email) => {
                            if (
                                emailSelect.find(`option[value='${email}']`)
                                    .length === 0
                            ) {
                                const newOption = new Option(
                                    email,
                                    email,
                                    true,
                                    true
                                );
                                emailSelect.append(newOption);
                            }
                        });

                        // Update Select2
                        emailSelect.trigger("change");

                        // Enable submit button
                        if (addButton) {
                            addButton.disabled = false;
                        }

                        showMessage(
                            `${emails.length} email${
                                emails.length !== 1 ? "s" : ""
                            } loaded`
                        );
                    } else {
                        showMessage("No valid emails found", true);
                    }
                } catch (error) {
                    showMessage("Error processing file", true);
                }
            };

            reader.onerror = function () {
                showMessage("Error reading file", true);
            };

            reader.readAsText(file);
        }

        // Enable clicking on dropzone
        if (dropzone && fileInput) {
            dropzone.addEventListener("click", () => fileInput.click());

            // Prevent default drag behaviors
            ["dragenter", "dragover", "dragleave", "drop"].forEach(
                (eventName) => {
                    dropzone.addEventListener(
                        eventName,
                        preventDefaults,
                        false
                    );
                    document.body.addEventListener(
                        eventName,
                        preventDefaults,
                        false
                    );
                }
            );

            // Handle dropzone highlighting
            ["dragenter", "dragover"].forEach((eventName) => {
                dropzone.addEventListener(
                    eventName,
                    () => dropzone.classList.add("active"),
                    false
                );
            });

            ["dragleave", "drop"].forEach((eventName) => {
                dropzone.addEventListener(
                    eventName,
                    () => dropzone.classList.remove("active"),
                    false
                );
            });

            // Handle file drop
            dropzone.addEventListener("drop", (e) => {
                const dt = e.dataTransfer;
                if (dt.files.length) {
                    fileInput.files = dt.files;
                    handleFile(dt.files[0]);
                }
            });
        }

        // Handle file selection
        if (fileInput) {
            fileInput.addEventListener("change", (e) => {
                if (e.target.files.length) {
                    handleFile(e.target.files[0]);
                }
            });
        }

        // Function to show message with auto-hide after 11 seconds
    }

    mentorInputPaste(e) {
        e.preventDefault();
        let pastedEmails = "";
        if (window.clipboardData && window.clipboardData.getData) {
            pastedEmails = window.clipboardData.getData("Text");
        } else if (e.clipboardData && e.clipboardData.getData) {
            pastedEmails = e.clipboardData.getData("text/plain");
        }

        if (pastedEmails.includes("\n")) {
            const newLinesIntoSpaces = pastedEmails.replace(/\n/g, " ");
            const newLinesIntoSpacesSplitted = newLinesIntoSpaces.split(" ");
            this.value = pastedEmails.replace(/./g, "");
            newLinesIntoSpacesSplitted.forEach((value) => {
                var tags = $("<option/>", { text: value });
                $("#group_mentor_emails").append(tags);
                $("#group_mentor_emails option").prop("selected", true);
            });
            $("#add-mentor-button").attr("disabled", false);
        } else {
            const pastedEmailsSplittedBySpace = pastedEmails.split(" ");
            this.value = pastedEmails.replace(/./g, "");
            pastedEmailsSplittedBySpace.forEach((value) => {
                var tags = $("<option/>", { text: value });
                $("#group_mentor_emails").append(tags);
                $("#group_mentor_emails option").prop("selected", true);
            });
            $("#add-mentor-button").attr("disabled", false);
        }
    }

    addMentorToGroup() {
        $("#group_mentor_emails").select2({
            tags: true,
            multiple: true,
            tokenSeparators: [",", " "],
        });
        $(".select2-selection input").attr("maxlength", "30");
        $(".select2-selection input").attr("id", "group_email_input_mentor");
        this.toggleButtonBasedOnEmails(
            "#group_mentor_emails",
            "#add-mentor-button"
        );
        $(".select2-selection input").attr(
            "data-action",
            "paste->groups#mentorInputPaste"
        );
        $("#group_mentor_emails").on("select2:select select2:unselect", () => {
            this.toggleButtonBasedOnEmails(
                "#group_mentor_emails",
                "#add-mentor-button"
            );
        });

        this.setupCSVUpload(
            ".csv-upload-container-mentor",
            "#group_mentor_emails",
            "#add-mentor-button"
        );
    }

    addMemberToGroup() {
        $("#group_member_emails").select2({
            tags: true,
            multiple: true,
            tokenSeparators: [",", " "],
        });
        $(".select2-selection input").attr("maxlength", "30");
        $(".select2-selection input").attr("id", "group_email_input");
        this.toggleButtonBasedOnEmails(
            "#group_member_emails",
            "#add-members-button"
        );
        $("#group_member_emails").on("select2:select select2:unselect", () => {
            this.toggleButtonBasedOnEmails(
                "#group_member_emails",
                "#add-members-button"
            );
        });
        document
            .querySelector(".select2-selection input")
            .addEventListener("paste", (e) => {
                e.preventDefault();
                let pastedEmails = "";
                if (window.clipboardData && window.clipboardData.getData) {
                    pastedEmails = window.clipboardData.getData("Text");
                } else if (e.clipboardData && e.clipboardData.getData) {
                    pastedEmails = e.clipboardData.getData("text/plain");
                }

                if (pastedEmails.includes("\n")) {
                    const newLinesIntoSpaces = pastedEmails.replace(/\n/g, " ");
                    const newLinesIntoSpacesSplitted =
                        newLinesIntoSpaces.split(" ");
                    this.value = pastedEmails.replace(/./g, "");
                    newLinesIntoSpacesSplitted.forEach((value) => {
                        var tags = $("<option/>", { text: value });
                        $("#group_member_emails").append(tags);
                        $("#group_member_emails option").prop("selected", true);
                    });
                    $("#add-members-button").attr("disabled", false);
                } else {
                    const pastedEmailsSplittedBySpace = pastedEmails.split(" ");
                    this.value = pastedEmails.replace(/./g, "");
                    pastedEmailsSplittedBySpace.forEach((value) => {
                        var tags = $("<option/>", { text: value });
                        $("#group_member_emails").append(tags);
                        $("#group_member_emails option").prop("selected", true);
                    });
                    $("#add-members-button").attr("disabled", false);
                }
            });

        this.setupCSVUpload(".csv-upload-container-member");
    }
}
