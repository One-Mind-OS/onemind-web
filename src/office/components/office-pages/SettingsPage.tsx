import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import { AboutSection } from "@/office/components/office-console/settings/AboutSection";
import { AdvancedSection } from "@/office/components/office-console/settings/AdvancedSection";
import { AppearanceSection } from "@/office/components/office-console/settings/AppearanceSection";
import { DeveloperSection } from "@/office/components/office-console/settings/DeveloperSection";
import { GatewaySection } from "@/office/components/office-console/settings/GatewaySection";
import { ProvidersSection } from "@/office/components/office-console/settings/ProvidersSection";
import { UpdateSection } from "@/office/components/office-console/settings/UpdateSection";
import { LoadingState } from "@/office/components/office-console/shared/LoadingState";
import { useConfigStore } from "@/office/store/console-stores/config-store";
import { useConsoleSettingsStore } from "@/office/store/console-stores/settings-store";

export function SettingsPage() {
  const { t } = useTranslation("console");
  const loading = useConfigStore((s) => s.loading);
  const fetchConfig = useConfigStore((s) => s.fetchConfig);
  const fetchStatus = useConfigStore((s) => s.fetchStatus);
  const devMode = useConsoleSettingsStore((s) => s.devModeUnlocked);

  useEffect(() => {
    void fetchConfig();
    void fetchStatus();
  }, [fetchConfig, fetchStatus]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
          {t("settings.title")}
        </h1>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{t("settings.description")}</p>
      </div>

      {loading ? (
        <LoadingState />
      ) : (
        <div className="space-y-4">
          <AppearanceSection />
          <ProvidersSection />
          <GatewaySection />
          <UpdateSection />
          <AdvancedSection />
          {devMode && <DeveloperSection />}
          <AboutSection />
        </div>
      )}
    </div>
  );
}
