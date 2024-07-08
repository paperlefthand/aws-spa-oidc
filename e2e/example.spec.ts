import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/spa-oidc/);
});

test('sign in', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'Sign-In with UserPool Hosted-UI' }).click();
});
