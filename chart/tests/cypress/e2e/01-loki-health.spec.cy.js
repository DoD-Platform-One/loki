  describe('Loki Test', 
    {
      retries:
      {
        runMode: 2,
      }
    }, () => {
    Cypress.on('uncaught:exception', (err, runnable) => {
      return false
    })
  
    if (Cypress.env("check_datasource")) {
  
        it('Check Loki is available as a data source in grafana and connected', {retries: 2}, function() {
            cy.wait(10000); 
            const saveOutputOptions = ['Data source is working', 'Data source successfully connected', 'Successfully connected to']
            const saveOutput = new RegExp(`${saveOutputOptions.join('|')}`, 'g')

            cy.visit(Cypress.env('grafana_url'))
            cy.performGrafanaLogin('admin', 'prom-operator')
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
            cy.get('[data-testid="data-testid Alert success"]').contains(saveOutput, { timeout: 180000 })
          })

        it('Test for Loki Dashboard log data', function () {
            cy.visit(`${Cypress.env('grafana_url')}/dashboards`); 
            cy.wait(1000);
            cy.loadGrafanaDashboard("Loki Dashboard quick search");
            cy.wait(1000);
            cy.get('[id=var-namespace]').click()
            cy.get('[data-testid*="istio-system"]').click()
            cy.get('[class$=-logs-row]').should('have.length.at.least', 10);
          });
    }
  })
