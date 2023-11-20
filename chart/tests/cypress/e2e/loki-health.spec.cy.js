  describe('Loki Test', function() {
    Cypress.on('uncaught:exception', (err, runnable) => {
      return false
    })
  
    if (Cypress.env("check_datasource")) {
  
        it('Check Loki is available as a data source in grafana and connected', function() {
            const saveOutputOptions = ['Data source is working', 'Data source successfully connected']
            const saveOutput = new RegExp(`${saveOutputOptions.join('|')}`, 'g')

            cy.visit(Cypress.env('grafana_url'))
            cy.get('input[name="user"]')
              .type('admin')
            cy.get('input[name="password"]')
              .type('prom-operator')
            cy.contains("Log in").click()
            cy.get('.page-dashboard').contains('Welcome', {timeout: 30000})
            // Visit the datasources page
            cy.visit(`${Cypress.env('grafana_url')}/connections/datasources`)
  
            // // // Enter 'loki' in the search field and 
            cy.get('input[type="text"]').first()
            .type('loki')
            // Click on the loki datasource
            cy.get('a').contains("Loki").click()
            // Click on the 'Save & test` button
            cy.get('button[type="submit"]').click()
            // Check to ensure the data source is working
            cy.get('.p-t-2').contains(saveOutput, { timeout: 10000 });
          })
    }
  })
