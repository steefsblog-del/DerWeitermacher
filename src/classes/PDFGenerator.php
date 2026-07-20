<?php
/**
 * PDF Generator Klasse
 */

namespace RSA21\Classes;

use Mpdf\Mpdf;
use Mpdf\Output\Destination;

class PDFGenerator {
    private $mpdf;

    public function __construct() {
        $this->mpdf = new Mpdf([
            'tempDir' => PDF_TEMP_DIR,
            'fontDir' => PDF_FONT_DIR,
            'default_font' => 'Arial',
        ]);
    }

    /**
     * Verkehrszeichenplan generieren
     */
    public function generateTrafficPlan($project, $signs) {
        $html = $this->buildTrafficPlanHTML($project, $signs);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Verkehrszeichenplan_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    /**
     * Umleitungsplan generieren
     */
    public function generateDiversionPlan($project, $signs) {
        $html = $this->buildDiversionPlanHTML($project, $signs);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Umleitungsplan_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    /**
     * Beschilderungsplan generieren
     */
    public function generateSignagePlan($project, $signs) {
        $html = $this->buildSignagePlanHTML($project, $signs);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Beschilderungsplan_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    /**
     * Verkehrsrechtliche Anordnung generieren
     */
    public function generateTrafficOrder($project) {
        $html = $this->buildTrafficOrderHTML($project);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Verkehrsrechtliche_Anordnung_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    /**
     * Kontrollprotokoll generieren
     */
    public function generateControlProtocol($project, $signs) {
        $html = $this->buildControlProtocolHTML($project, $signs);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Kontrollprotokoll_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    /**
     * Baustellendokumentation generieren
     */
    public function generateSiteDocumentation($project) {
        $html = $this->buildSiteDocumentationHTML($project);
        $this->mpdf->WriteHTML($html);
        return $this->mpdf->Output('Baustellendokumentation_' . $project['id'] . '.pdf', Destination::FILE_PATH);
    }

    private function buildTrafficPlanHTML($project, $signs) {
        return "<h1>Verkehrszeichenplan</h1><p>Projekt: {$project['project_name']}</p>";
    }

    private function buildDiversionPlanHTML($project, $signs) {
        return "<h1>Umleitungsplan</h1><p>Projekt: {$project['project_name']}</p>";
    }

    private function buildSignagePlanHTML($project, $signs) {
        return "<h1>Beschilderungsplan</h1><p>Projekt: {$project['project_name']}</p>";
    }

    private function buildTrafficOrderHTML($project) {
        return "<h1>Verkehrsrechtliche Anordnung</h1><p>Projekt: {$project['project_name']}</p>";
    }

    private function buildControlProtocolHTML($project, $signs) {
        return "<h1>Kontrollprotokoll</h1><p>Projekt: {$project['project_name']}</p>";
    }

    private function buildSiteDocumentationHTML($project) {
        return "<h1>Baustellendokumentation</h1><p>Projekt: {$project['project_name']}</p>";
    }
}
