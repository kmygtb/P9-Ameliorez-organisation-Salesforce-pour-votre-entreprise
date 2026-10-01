import { createElement } from 'lwc';
import Orders from 'c/orders';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

jest.mock(
    '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount',
    () => {
        return { default: jest.fn() };
    },
    { virtual: true }
);

function flushPromises() {
    return new Promise((resolve) => setTimeout(resolve, 0));
}

describe('c-orders', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('affiche le message de succes quand le montant est positif', () => {
        getSumOrdersByAccount.mockResolvedValue(1500);

        const element = createElement('c-orders', { is: Orders });
        document.body.appendChild(element);

        return flushPromises().then(() => {
            const successDiv = element.shadowRoot.querySelector('.slds-theme_success');
            const errorDiv = element.shadowRoot.querySelector('.slds-theme_error');

            expect(successDiv).not.toBeNull();
            expect(errorDiv).toBeNull();
        });
    });

    it('affiche le message erreur quand le montant est a zero', () => {
        getSumOrdersByAccount.mockResolvedValue(0);

        const element = createElement('c-orders', { is: Orders });
        document.body.appendChild(element);

        return flushPromises().then(() => {
            const successDiv = element.shadowRoot.querySelector('.slds-theme_success');
            const errorDiv = element.shadowRoot.querySelector('.slds-theme_error');

            expect(successDiv).toBeNull();
            expect(errorDiv).not.toBeNull();
        });
    });

    it('affiche le message erreur quand il n\'y a aucune commande', () => {
        getSumOrdersByAccount.mockResolvedValue(null);

        const element = createElement('c-orders', { is: Orders });
        document.body.appendChild(element);

        return flushPromises().then(() => {
            const successDiv = element.shadowRoot.querySelector('.slds-theme_success');
            const errorDiv = element.shadowRoot.querySelector('.slds-theme_error');

            expect(successDiv).toBeNull();
            expect(errorDiv).not.toBeNull();
        });
    });
});