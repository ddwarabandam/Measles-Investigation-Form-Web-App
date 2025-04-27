# CRF Investigation Form Web app: global.R or top of app.R
library(shiny)
library(openxlsx)
library(dplyr)
library(lubridate)
library(shinyjs)  # Make sure it's installed
library(rsconnect)

# Define the list of required packages
#required_packages <- c(
 # "shiny",
#  "openxlsx",
 # "dplyr",
  #"lubridate",
  #"shinyjs"
#)

# Check for packages that are not installed, and install them
#new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
#if(length(new_packages)) {
 # install.packages(new_packages)
#}

# Load all the required packages
#invisible(lapply(required_packages, library, character.only = TRUE))

# This is the default path for saving – user can modify this
default_path <- " "
if (!dir.exists(default_path)) dir.create(default_path, recursive = TRUE)


# CRF: ui.R or inside shinyApp(ui = ..., server = ...)
ui <- fluidPage(
  useShinyjs(),  # Activate shinyjs
  tags$head(
    tags$script(HTML("
      var idleTimer;
      function resetTimer() {
        clearTimeout(idleTimer);
        idleTimer = setTimeout(function(){
          Shiny.setInputValue('session_timeout_warning', new Date());
        }, 10 * 60 * 1000);  // 10 minutes of idle time
      }
      $(document).on('mousemove keydown click', resetTimer);
      resetTimer();
    "))
  ),
  
  titlePanel("Measles Case Report Form (Investigation Form) Web App"),
  tabsetPanel(
    type = "tabs",
    
    # ----------------------- 1. Case Info Tab -----------------------
    tabPanel("Case Info",
             textInput("case_id", "Case ID", placeholder = "e.g., NE-2024-00123"),
             textInput("state_case_id", "State Case ID", placeholder = "e.g., 24ME123456"),
             textInput("lab_id", "Lab ID", placeholder = "e.g., LAB456789"),
             textInput("nndss_id", "NNDSS ID", placeholder = "e.g., 1234567890"),
             textInput("patient_name", "Patient Name", placeholder = "e.g., Smith, John"),
             dateInput("report_date", "Reported to Health Department"),
             dateInput("invest_start_date", "Investigation Start Date"),
             dateInput("db_entry_date", "Database Entry Date"),
             dateInput("db_lastentry_date", "Database Last Entry Date"),
             textInput("interviewer_name", "Interviewer Name", placeholder = "e.g., Jane Doe"),
             textInput("interviewer_contact", "Interviewer Contact", placeholder = "e.g., jane.doe@health.org / 402-555-1234"),
             textAreaInput("call_log", "Call Log Details", placeholder = "e.g., Attempted Interview, April 1, 2025: 10 AM"),
             textAreaInput("additional_basic_comments", "Additional Basic Comments", placeholder = "e.g., Needs assistance with language interpretation")

             
    ),
    
    # ----------------------- 2. Demographics -----------------------
    tabPanel("Demographics",
             textInput("respondent_name", "Respondent Name", placeholder = "e.g., Mary Smith"),
             textInput("respondent_relation", "Relation to Patient", placeholder = "e.g., Mother"),
             textInput("address", "Address", placeholder = "e.g., 123 Maple St Apt 4B"),
             textInput("city", "City", placeholder = "e.g., Hastings"),
             textInput("county", "County", placeholder = "e.g., Adams"),
             textInput("state_form", "State", placeholder = "e.g., Nebraska"),
             textInput("zip", "Zip Code", placeholder = "e.g., 68901"),
             textInput("telephone", "Telephone", placeholder = "e.g., 402-555-6789"),
             textInput("residence_country", "Country of Residence", placeholder = "e.g., United States"),
             selectInput("sex_at_birth", "Sex at Birth", c(" ", "Male", "Female", "Unknown")),
             numericInput("age", "Age", value = NA, min = 0),
             dateInput("dob", "Date of Birth"),
             selectInput("hispanic_latino", "Hispanic/Latino", c(" ", "Yes", "No", "Unknown")),
             selectInput("race", "Race", 
                         c(" ", "White", "Black/African American", "Asian/Pacific Islander",
                           "American Indian/Alaska Native", "Other", "Unknown")),
             textAreaInput("additional_demo_comments", "Additional Demographic Comments", placeholder = "e.g., Any tribal affiliations, extra demographics")
             
    ),
    
    # ----------------------- 3. Clinical -----------------------
    tabPanel("Clinical",
             dateInput("symptom_onset_date", "Symptom Onset Date"),
             radioButtons("symptom_rash", "Rash?", c(" ", "Yes", "No", "Unknown")),
             dateInput("rash_onset_date", "Rash Onset Date"),
             radioButtons("rash_generalized", "Rash Generalized?", c(" ", "Yes", "No", "Unknown")),
             textInput("rash_desc", "Rash Description", placeholder = "e.g., Red raised maculopapular rash"),
             radioButtons("rash_current", "Rash Still Present?", c(" ", "Yes", "No", "Unknown")),
             numericInput("rash_duration_days", "Rash Duration (days)", value = NA),
             radioButtons("symptom_fever", "Fever?", c(" ", "Yes", "No", "Unknown")),
             dateInput("fever_onset_date", "Fever Onset Date"),
             numericInput("max_temp", "Max Temperature", value = NA),
             radioButtons("temp_scale", "Temperature Scale", c("°F", "°C")),
             radioButtons("symptom_cough", "Cough?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_coryza", "Coryza?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_conjunctivitis", "Conjunctivitis?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_otitis", "Otitis?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_pneumonia", "Pneumonia?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_diarrhea", "Diarrhea?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_vomiting", "Vomiting?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_dehydration", "Dehydration?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_low_platelets", "Thrombocytopenia?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("symptom_encephalitis", "Encephalitis?", c(" ", "Yes", "No", "Unknown")),
             textAreaInput("symptom_other", "Other Symptoms", placeholder = "e.g., Headache, chills", height = "60px"),
             textAreaInput("additional_clinical_comments", "Additional Clinical Comments", placeholder = "e.g., Case is not improving or Case situation is getting worse")
    ),
    
    # ----------------------- 4. Exposure/Contact -----------------------
    tabPanel("Exposure/ Contagious Period Details",
             radioButtons("recent_travel", "Travel Outside US (21 days)?", c(" ", "Yes", "No", "Unknown")),
             dateInput("travel_depart_date", "Departure Date"),
             dateInput("travel_return_date", "Return Date"),
             textAreaInput("countries_visited", "Countries Visited", placeholder = "e.g., Australia, India, Italy"),
             radioButtons("exposure_source_contact", "Remember Any Close Contact with a Contagious Case during Exposure Period?(Source Case)", c(" ", "Yes", "No", "Unknown")),
             textInput("source_case_id", "Source Case ID if known", placeholder = "e.g., NE-2024-00098"),
             textAreaInput("comments_source_case ", "Any Comments about Suspect Source - Measles Case to Whom this Case got Exposed?", placeholder = " My friend's daugther 2 years old seemed very sick with fever and rashes last month during a weekend barbeque event, Mar 23, 2025."),
             textAreaInput("exposure_period_contact_details", "Exposure Period Travel History (Exposure period = 7-21 days Before Initial Symptoms Onset Date): Ask about Date of travel, Location, Duration of Time Spent, Est. No. of people around, Transporation used;", placeholder = "Note: Write info with Comma Separation & use semicolon ';' for each day ending; e.g., 21Day, 03/20/25, School(ABC), 8AM to 5PM, 100 people, private car; 20Day, 03/21/25, Movie theater xyz, 2PM-5PM, 200 people, own car, Restaurant XYZ, 6PM-8PM, 50 people, own car;", height = "60px"),
             textAreaInput("contagious_period_contact_details", "Contagious Period Travel History (Contagious period = 4 days Before Rash Onset Date to 4 days after): Ask about Date of travel, Location, Duration of Time Spent, Est. No. of people around, Transporation used;", placeholder = "Note: Write info with Comma Separation  & use semicolon ';' for each day ending, - & + to denote before & after period to Rash Onset Date; e.g., -4Day, 04/02/25, Hospital(ABC), 1PM to 5PM, X people, private car; +1Day, 04/07/25, Friends house xyz, 2PM-5PM, 5 people, own car;", height = "60px"),
             textAreaInput("household_contacts_details", "Household Contacts Details",placeholder = "e.g., Father, Mother, 2025-03-23 to 2025-04-01", height = "100px"),
             textAreaInput("additional_contact_comments","Exposure or Contagious Period Additional Comments", placeholder = "e.g., Potentially exposed neighbors and a visiting friend on March 27, 2025 at home")
    ),
    
    # ----------------------- 5. Vaccination -----------------------
    tabPanel("Vaccination & PEP",
             radioButtons("vaccine_received", "Received MMR Vaccine?", c(" ", "Yes", "No", "Unknown")),
             numericInput("vaccine_doses_num", "Doses Received", value = NA),
             dateInput("vaccine_dose1_date", "Dose 1 Date"),
             dateInput("vaccine_dose2_date", "Dose 2 Date"),
             dateInput("vaccine_dose3_date", "Dose 3 Date"),
             radioButtons("pep_received", "Received PEP?", c(" ", "Yes", "No", "Unknown")),
             selectInput("pep_type", "Type of PEP", c(" ", "Vaccine", "Immunoglobulin (IG)", "Unknown")),
             dateInput("pep_date", "PEP Date"),
             radioButtons("pep_within_timeframe", "PEP Within 3/6 Days?", c(" ", "Yes", "No", "Unknown")),
             selectInput("ig_admin_method", "IG Route", c(" ", "Intramuscular", "Intravenous", "Unknown")),
             textAreaInput("additional_vaccine_comments", "Additional Vaccines Comments", placeholder = "e.g., Case's parents are vaccine hesitant: needs more education")
    ),
    
    # ----------------------- 6. Healthcare & Lab Info -----------------------
    tabPanel("Healthcare & Labs",
             radioButtons("healthcare_visited", "Visited Healthcare?", c(" ", "Yes", "No", "Unknown")),
             textInput("healthcare_location", "Healthcare Location Type", placeholder = "e.g., Clinic, ER"),
             dateInput("healthcare_visit_date", "Visit Date"),
             textInput("healthcare_facility", "Facility Name", placeholder = "e.g., Mary Lanning Memorial Hospital"),
             radioButtons("hospitalized", "Hospitalized?", c(" ", "Yes", "No", "Unknown")),
             textInput("hospital_name", "Hospital Name", placeholder = "e.g., Bryan Health Medical Center"),
             dateInput("hospital_admit_date", "Admission Date"),
             dateInput("hospital_discharge_date", "Discharge Date"),
             radioButtons("patient_death", "Death?", c(" ","Yes", "No", "Unknown")),
             dateInput("death_date", "Date of Death"),
             textAreaInput("additional_comments", "Additional Comments", placeholder = "e.g., 2nd Hospital Admission: MLH, March 29-31, 2025"),
             
             radioButtons("testing_performed", "Testing Performed?", c(" ", "Yes", "No", "Unknown")),
             radioButtons("specimen_permission", "Permission for Specimen?", c(" ","Yes", "No", "Unknown")),
             textInput("test_pcr_result", "PCR Result", placeholder = "e.g., Positive"),
             dateInput("test_pcr_date", "PCR Date"),
             textInput("test_pcr_lab", "PCR Lab", placeholder = "e.g., Nebraska Public Health Lab"),
             textInput("test_igm_result", "IgM Result", placeholder = "e.g., Pending"),
             dateInput("test_igm_date", "IgM Date"),
             textInput("test_igm_lab", "IgM Lab", placeholder = "e.g., UNMC Virology"),
             textInput("test_igg_acute_result", "IgG Acute Result", placeholder = "e.g., Negative"),
             dateInput("test_igg_acute_date", "IgG Acute Date"),
             textInput("test_igg_acute_lab", "IgG Acute Lab", placeholder = "e.g., Mayo Clinic"),
             textInput("test_igg_conval_result", "IgG Convalescent Result", placeholder = "e.g., Positive"),
             dateInput("test_igg_conval_date", "IgG Convalescent Date"),
             textInput("test_igg_conval_lab", "IgG Conval Lab", placeholder = "e.g., Quest Diagnostics"),
             textInput("test_genotype_result", "Genotype Result", placeholder = "e.g., D8, B3"),
             dateInput("test_genotype_date", "Genotype Date"),
             textInput("test_genotype_lab", "Genotype Lab", placeholder = "e.g., CDC"),
             textInput("test_meva_result", "MeVA Result", placeholder = "e.g., Negative"),
             dateInput("test_meva_date", "MeVA Date"),
             textInput("test_meva_lab", "MeVA Lab", placeholder = "e.g., LabCorp"),
             textAreaInput("additional_healthcare_lab_comments", "Additional Healthcare & Lab Comments", placeholder = "e.g., Interested in learning more about vaccines")
    ),
    
    # ----------------------- NEW TAB: Final Status -----------------------
    tabPanel("Final Status",
             selectInput("final_status", "Final Case Classification",
                         choices = c(" ", "Confirmed - Lab", "Confirmed - Epi", "Probable", "Suspect", "Not a Case", "Unknown")),
             selectInput("working_status", "Working Case Classification",
                         choices = c(" ", "Confirmed - Lab", "Confirmed - Epi", "Probable", "Suspect", "Not a Case", "Unknown")),
             selectInput("outbreak_related", "Outbreak Related?", choices = c(" ", "Yes", "No", "Unknown")),
             textInput("outbreak_name", "Outbreak Name", placeholder = "e.g., UNK-MEASLES-SPRING-2024"),
             selectInput("import_status", "Import Status",
                         choices = c(" ", "International importation", "U.S. acquired", "Unknown")),
             selectInput("us_acquired_detail", "U.S. Acquired Detail",
                         choices = c(" ", "Import-linked case", "Imported-virus case", "Endemic case", "Unknown source case")),
             textAreaInput("additional_case_comments", "Additional Case Comments", placeholder = "e.g., Overall, case is isolating, compliant with quarantine guidelines")
    ),
    
    
    
    # ----------------------- 7. Final Tab: Save & Review -----------------------
    tabPanel("Submit & Review",
             actionButton("save", "Save Case"),
             downloadButton("download_data", "Download All Cases"),
             verbatimTextOutput("save_status"),
             h4("Preview Saved Cases This Session"),
             tableOutput("session_data")
    )
  ),
  tabPanel("About",
           br(),
           tags$h4("📘 About This Measles Investigation Form Web  App (Alphav3.1)"),
           tags$p("This web application is designed to support fast and accurate measles case investigations and contact tracing.
            It streamlines case data entry, organizes key information, and prepares datasets for automated analysis through the ETL and outbreak analytics companion app.
            Together, these tools help public health teams summarize cases, model epidemic growth, forecast outbreaks, and guide timely decision-making."),
           
           tags$hr(),
           
           tags$p(style = "font-size: 12px; color: gray;",
                  HTML(paste0(
                    "© 2025 ddwarabandam. All rights reserved. ",
                    "Designed with reference to the CDC Measles Standardized Case Investigation Form (",
                    "<a href='https://www.cdc.gov/measles/downloads/2024-dvd-measles-investigation-form.pdf' target='_blank'>source</a>). ",
                    "For documentation, visit the ",
                    "<a href='https://github.com/ddwarabandam/NEMeasleswebETLalpha/blob/main/README.md' target='_blank'>README</a>, ",
                    "<a href='https://github.com/ddwarabandam/NEMeasleswebETLalpha' target='_blank'>ETL App</a>, ",
                    "and <b>CRF App - Alpha v3.1</b>."
                  ))
           )
  )

)


# CRF: server.R
server <- function(input, output, session) {
  
  
  safe_value <- function(x) {
    if (is.null(x) || length(x) == 0) {
      return(NA)  # Always return a scalar, even if NA
    }
    if (inherits(x, "Date")) {
      return(as.character(x))  # Convert Dates to string safely
    }
    return(x)  # return numeric or character as-is
  }
  
  `%||%` <- function(a, b) if (!is.null(a)) a else b

  
  
  
  # Temporary storage for current session cases
  cases <- reactiveVal(data.frame())
  

  observeEvent(input$save, {
    # Create a new row with all values as characters
    new_row <- data.frame(
      # 1. Basic Case Info
      case_id = safe_value(input$case_id),
      state_case_id = safe_value(input$state_case_id),
      lab_id = safe_value(input$lab_id),
      nndss_id = safe_value(input$nndss_id),
      patient_name = safe_value(input$patient_name),
      report_date = safe_value(input$report_date),
      invest_start_date = safe_value(input$invest_start_date),
      db_entry_date = safe_value(input$db_entry_date),
      db_lastentry_date = safe_value(input$db_lastentry_date),
      interviewer_name = safe_value(input$interviewer_name),
      interviewer_contact = safe_value(input$interviewer_contact),
      additional_basic_comments = safe_value(input$additional_basic_comments),
      
      # 3. Demographics
      respondent_name = safe_value(input$respondent_name),
      respondent_relation = safe_value(input$respondent_relation),
      address = safe_value(input$address),
      city = safe_value(input$city),
      county = safe_value(input$county),
      state_form = safe_value(input$state_form),
      zip = safe_value(input$zip),
      telephone = safe_value(input$telephone),
      residence_country = safe_value(input$residence_country),
      sex_at_birth = safe_value(input$sex_at_birth),
      age = safe_value(input$age),
      dob = safe_value(input$dob),
      hispanic_latino = safe_value(input$hispanic_latino),
      race = safe_value(input$race),
      additional_demo_comments = safe_value(input$additional_demo_comments),
      
      # 4. Clinical
      symptom_onset_date = safe_value(input$symptom_onset_date),
      symptom_rash = safe_value(input$symptom_rash),
      rash_onset_date = safe_value(input$rash_onset_date),
      rash_generalized = safe_value(input$rash_generalized),
      rash_desc = safe_value(input$rash_desc),
      rash_current = safe_value(input$rash_current),
      rash_duration_days = safe_value(input$rash_duration_days),
      symptom_fever = safe_value(input$symptom_fever),
      fever_onset_date = safe_value(input$fever_onset_date),
      max_temp = safe_value(input$max_temp),
      temp_scale = safe_value(input$temp_scale),
      symptom_cough = safe_value(input$symptom_cough),
      symptom_coryza = safe_value(input$symptom_coryza),
      symptom_conjunctivitis = safe_value(input$symptom_conjunctivitis),
      symptom_otitis = safe_value(input$symptom_otitis),
      symptom_pneumonia = safe_value(input$symptom_pneumonia),
      symptom_diarrhea = safe_value(input$symptom_diarrhea),
      symptom_vomiting = safe_value(input$symptom_vomiting),
      symptom_dehydration = safe_value(input$symptom_dehydration),
      symptom_low_platelets = safe_value(input$symptom_low_platelets),
      symptom_encephalitis = safe_value(input$symptom_encephalitis),
      symptom_other = safe_value(input$symptom_other),
      additional_clinical_comments = safe_value(input$additional_clinical_comments),
      
      # 6. Exposure & Contact
      recent_travel = safe_value(input$recent_travel),
      travel_depart_date = safe_value(input$travel_depart_date),
      travel_return_date = safe_value(input$travel_return_date),
      countries_visited = safe_value(input$countries_visited),
      exposure_source_contact = safe_value(input$exposure_source_contact),
      source_case_id = safe_value(input$source_case_id),
      comments_source_case = safe_value(input$comments_source_case),
      exposure_period_contact_details = safe_value(input$exposure_period_contact_details),
      contagious_period_contact_details = safe_value(input$contagious_period_contact_details),
      household_contacts_details = safe_value(input$household_contacts_details),
      additional_contact_comments = safe_value(input$additional_contact_comments),
      
      # 7. Vaccination & PEP
      vaccine_received = safe_value(input$vaccine_received),
      vaccine_doses_num = safe_value(input$vaccine_doses_num),
      vaccine_dose1_date = safe_value(input$vaccine_dose1_date),
      vaccine_dose2_date = safe_value(input$vaccine_dose2_date),
      vaccine_dose3_date = safe_value(input$vaccine_dose3_date),
      pep_received = safe_value(input$pep_received),
      pep_type = safe_value(input$pep_type),
      pep_date = safe_value(input$pep_date),
      pep_within_timeframe = safe_value(input$pep_within_timeframe),
      ig_admin_method = safe_value(input$ig_admin_method),
      additional_vaccine_comments = safe_value(input$additional_vaccine_comments),
      
      # 5. Healthcare
      healthcare_visited = safe_value(input$healthcare_visited),
      healthcare_location = safe_value(input$healthcare_location),
      healthcare_visit_date = safe_value(input$healthcare_visit_date),
      healthcare_facility = safe_value(input$healthcare_facility),
      hospitalized = safe_value(input$hospitalized),
      hospital_name = safe_value(input$hospital_name),
      hospital_admit_date = safe_value(input$hospital_admit_date),
      hospital_discharge_date = safe_value(input$hospital_discharge_date),
      patient_death = safe_value(input$patient_death),
      death_date = safe_value(input$death_date),
      
      # 8. Laboratory
      testing_performed = safe_value(input$testing_performed),
      specimen_permission = safe_value(input$specimen_permission),
      test_pcr_result = safe_value(input$test_pcr_result),
      test_pcr_date = safe_value(input$test_pcr_date),
      test_pcr_lab = safe_value(input$test_pcr_lab),
      test_igm_result = safe_value(input$test_igm_result),
      test_igm_date = safe_value(input$test_igm_date),
      test_igm_lab = safe_value(input$test_igm_lab),
      test_igg_acute_result = safe_value(input$test_igg_acute_result),
      test_igg_acute_date = safe_value(input$test_igg_acute_date),
      test_igg_acute_lab = safe_value(input$test_igg_acute_lab),
      test_igg_conval_result = safe_value(input$test_igg_conval_result),
      test_igg_conval_date = safe_value(input$test_igg_conval_date),
      test_igg_conval_lab = safe_value(input$test_igg_conval_lab),
      test_genotype_result = safe_value(input$test_genotype_result),
      test_genotype_date = safe_value(input$test_genotype_date),
      test_genotype_lab = safe_value(input$test_genotype_lab),
      test_meva_result = safe_value(input$test_meva_result),
      test_meva_date = safe_value(input$test_meva_date),
      test_meva_lab = safe_value(input$test_meva_lab),
      additional_healthcare_lab_comments = safe_value(input$additional_healthcare_lab_comments),
      
      # 2. Final Status
      final_status = safe_value(input$final_status),
      working_status = safe_value(input$working_status),
      outbreak_related = safe_value(input$outbreak_related),
      outbreak_name = safe_value(input$outbreak_name),
      import_status = safe_value(input$import_status),
      us_acquired_detail = safe_value(input$us_acquired_detail),
      additional_comments = safe_value(input$additional_comments),
      
      stringsAsFactors = FALSE
    )
    
    
    # Append to reactive data frame
    updated_data <- bind_rows(cases(), new_row)
    cases(updated_data)
    
    output$save_status <- renderText({
      paste0("Saved case: ", input$case_id)
    })
  })
  
  # ✅ Place this outside observeEvent(input$save)
  observeEvent(input$session_timeout_warning, {
    showModal(modalDialog(
      title = "⚠️ Idle Warning",
      "You’ve been idle for 10 minutes. Your session will expire soon. Please save or download your data.",
      easyClose = TRUE,
      footer = modalButton("OK")
    ))
  })
  
  
  # Show current in-session data
  output$session_data <- renderTable({
    cases()
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("Measles_Cases_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      write.xlsx(cases(), file, rowNames = FALSE)
    }
  )
  
  
  
  
  
}


# Run the app
shinyApp(ui = ui, server = server)
