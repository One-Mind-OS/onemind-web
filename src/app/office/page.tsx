"use client";

import dynamic from "next/dynamic";
import { Suspense, useState } from "react";

const FloorPlan = dynamic(
  () =>
    import("@/office/components/office-2d/FloorPlan").then(
      (mod) => mod.FloorPlan
    ),
  { ssr: false }
);

const Scene3D = dynamic(
  () =>
    import("@/office/components/office-3d/Scene3D").then(
      (mod) => mod.default ?? mod
    ),
  { ssr: false }
);

export default function OfficePage() {
  const [viewMode, setViewMode] = useState<"2d" | "3d">("2d");

  return (
    <div className="relative h-full w-full overflow-hidden">
      <div className="absolute top-4 right-4 z-10 flex gap-2">
        <button
          onClick={() => setViewMode("2d")}
          className={`rounded-md px-3 py-1.5 text-sm font-medium transition ${
            viewMode === "2d"
              ? "bg-white text-black shadow"
              : "bg-white/10 text-white/60 hover:bg-white/20"
          }`}
        >
          2D
        </button>
        <button
          onClick={() => setViewMode("3d")}
          className={`rounded-md px-3 py-1.5 text-sm font-medium transition ${
            viewMode === "3d"
              ? "bg-white text-black shadow"
              : "bg-white/10 text-white/60 hover:bg-white/20"
          }`}
        >
          3D
        </button>
      </div>

      <Suspense
        fallback={
          <div className="flex h-full items-center justify-center text-white/40">
            Loading office...
          </div>
        }
      >
        {viewMode === "3d" ? <Scene3D /> : <FloorPlan />}
      </Suspense>
    </div>
  );
}
