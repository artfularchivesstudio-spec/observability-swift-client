#!/bin/bash
#
# 📸 Generate Snapshot Test Dashboard HTML
#
# "The cosmic script that transforms snapshots into a beautiful visual gallery"
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SNAPSHOT_DIR="$PROJECT_ROOT/__Snapshots__"
DASHBOARD_DIR="$PROJECT_ROOT/snapshot-dashboard"
DASHBOARD_HTML="$DASHBOARD_DIR/index.html"

echo "🎨 Generating Snapshot Test Dashboard..."

# Create dashboard directory
mkdir -p "$DASHBOARD_DIR"

# Find all snapshot images
SNAPSHOTS=$(find "$SNAPSHOT_DIR" -name "*.png" -type f | sort)

if [ -z "$SNAPSHOTS" ]; then
    echo "⚠️  No snapshots found. Run snapshot tests first."
    exit 1
fi

# Generate HTML
cat > "$DASHBOARD_HTML" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📸 Observability Snapshot Test Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
            text-align: center;
        }
        
        h1 {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #666;
            font-size: 1.1em;
        }
        
        .stats {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 20px;
            flex-wrap: wrap;
        }
        
        .stat {
            background: #f8f9fa;
            padding: 15px 25px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-label {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }
        
        .filters {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }
        
        .filter-group {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .filter-group label {
            font-weight: 600;
            color: #333;
        }
        
        .filter-btn {
            padding: 8px 16px;
            border: 2px solid #e0e0e0;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 0.9em;
        }
        
        .filter-btn:hover {
            border-color: #667eea;
            color: #667eea;
        }
        
        .filter-btn.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
        }
        
        .snapshot-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .snapshot-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
        }
        
        .snapshot-header {
            padding: 15px;
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .snapshot-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .snapshot-meta {
            font-size: 0.85em;
            color: #666;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .badge {
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75em;
            font-weight: 600;
        }
        
        .badge-ios {
            background: #007AFF;
            color: white;
        }
        
        .badge-macos {
            background: #0071E3;
            color: white;
        }
        
        .badge-light {
            background: #FFD700;
            color: #333;
        }
        
        .badge-dark {
            background: #1C1C1E;
            color: white;
        }
        
        .snapshot-image {
            width: 100%;
            height: auto;
            display: block;
            cursor: pointer;
        }
        
        .snapshot-image:hover {
            opacity: 0.9;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.9);
            justify-content: center;
            align-items: center;
        }
        
        .modal.active {
            display: flex;
        }
        
        .modal-content {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
        }
        
        .modal-close {
            position: absolute;
            top: 20px;
            right: 30px;
            color: white;
            font-size: 40px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .no-results {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
            color: #666;
        }
        
        .no-results-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>📸 Observability Snapshot Test Dashboard</h1>
            <p class="subtitle">Visual regression testing results across all platforms and color schemes</p>
            <div class="stats" id="stats">
                <!-- Stats will be populated by JavaScript -->
            </div>
        </header>
        
        <div class="filters">
            <div class="filter-group">
                <label>Platform:</label>
                <button class="filter-btn active" data-filter="platform" data-value="all">All</button>
                <button class="filter-btn" data-filter="platform" data-value="iOS">iOS</button>
                <button class="filter-btn" data-filter="platform" data-value="macOS">macOS</button>
            </div>
            <div class="filter-group">
                <label>Color Scheme:</label>
                <button class="filter-btn active" data-filter="scheme" data-value="all">All</button>
                <button class="filter-btn" data-filter="scheme" data-value="Light">Light</button>
                <button class="filter-btn" data-filter="scheme" data-value="Dark">Dark</button>
            </div>
            <div class="filter-group">
                <label>Device:</label>
                <button class="filter-btn active" data-filter="device" data-value="all">All</button>
                <button class="filter-btn" data-filter="device" data-value="iPhone15Pro">iPhone 15 Pro</button>
                <button class="filter-btn" data-filter="device" data-value="iPhoneSE">iPhone SE</button>
                <button class="filter-btn" data-filter="device" data-value="iPadPro">iPad Pro</button>
                <button class="filter-btn" data-filter="device" data-value="macBookPro">MacBook Pro</button>
            </div>
        </div>
        
        <div class="gallery" id="gallery">
            <!-- Snapshots will be populated by JavaScript -->
        </div>
        
        <div class="modal" id="modal">
            <span class="modal-close" onclick="closeModal()">&times;</span>
            <img class="modal-content" id="modalImage" src="" alt="Snapshot">
        </div>
    </div>
    
    <script>
        const snapshots = [
EOF

# Process each snapshot
SNAPSHOT_COUNT=0
for snapshot in $SNAPSHOTS; do
    SNAPSHOT_COUNT=$((SNAPSHOT_COUNT + 1))
    RELATIVE_PATH=$(echo "$snapshot" | sed "s|$PROJECT_ROOT/||")
    FILENAME=$(basename "$snapshot")
    
    # Extract metadata from filename (format: TestName_ConfigName.png)
    # Example: testDashboardView_iOS_Light_iPhone15Pro.png
    BASENAME=$(basename "$snapshot" .png)
    
    # Parse metadata
    if [[ $BASENAME == *"iOS"* ]]; then
        PLATFORM="iOS"
    elif [[ $BASENAME == *"macOS"* ]]; then
        PLATFORM="macOS"
    else
        PLATFORM="Unknown"
    fi
    
    if [[ $BASENAME == *"Light"* ]]; then
        SCHEME="Light"
    elif [[ $BASENAME == *"Dark"* ]]; then
        SCHEME="Dark"
    else
        SCHEME="Unknown"
    fi
    
    if [[ $BASENAME == *"iPhone15Pro"* ]]; then
        DEVICE="iPhone15Pro"
    elif [[ $BASENAME == *"iPhoneSE"* ]]; then
        DEVICE="iPhoneSE"
    elif [[ $BASENAME == *"iPadPro"* ]]; then
        DEVICE="iPadPro"
    elif [[ $BASENAME == *"macBookPro"* ]]; then
        DEVICE="macBookPro"
    else
        DEVICE="Unknown"
    fi
    
    # Extract test name
    TEST_NAME=$(echo "$BASENAME" | sed -E 's/_(iOS|macOS)_.*//')
    
    cat >> "$DASHBOARD_HTML" << EOF
            {
                path: "$RELATIVE_PATH",
                filename: "$FILENAME",
                testName: "$TEST_NAME",
                platform: "$PLATFORM",
                scheme: "$SCHEME",
                device: "$DEVICE"
            },
EOF
done

cat >> "$DASHBOARD_HTML" << 'EOF'
        ];
        
        // Initialize dashboard
        function initDashboard() {
            updateStats();
            renderGallery(snapshots);
            setupFilters();
        }
        
        function updateStats() {
            const stats = {
                total: snapshots.length,
                ios: snapshots.filter(s => s.platform === 'iOS').length,
                macos: snapshots.filter(s => s.platform === 'macOS').length,
                light: snapshots.filter(s => s.scheme === 'Light').length,
                dark: snapshots.filter(s => s.scheme === 'Dark').length
            };
            
            document.getElementById('stats').innerHTML = `
                <div class="stat">
                    <div class="stat-value">${stats.total}</div>
                    <div class="stat-label">Total Snapshots</div>
                </div>
                <div class="stat">
                    <div class="stat-value">${stats.ios}</div>
                    <div class="stat-label">iOS</div>
                </div>
                <div class="stat">
                    <div class="stat-value">${stats.macos}</div>
                    <div class="stat-label">macOS</div>
                </div>
                <div class="stat">
                    <div class="stat-value">${stats.light}</div>
                    <div class="stat-label">Light Mode</div>
                </div>
                <div class="stat">
                    <div class="stat-value">${stats.dark}</div>
                    <div class="stat-label">Dark Mode</div>
                </div>
            `;
        }
        
        function renderGallery(filteredSnapshots) {
            const gallery = document.getElementById('gallery');
            
            if (filteredSnapshots.length === 0) {
                gallery.innerHTML = `
                    <div class="no-results">
                        <div class="no-results-icon">🔍</div>
                        <h2>No snapshots match the selected filters</h2>
                        <p>Try adjusting your filter selections</p>
                    </div>
                `;
                return;
            }
            
            gallery.innerHTML = filteredSnapshots.map(snapshot => `
                <div class="snapshot-card" data-platform="${snapshot.platform}" data-scheme="${snapshot.scheme}" data-device="${snapshot.device}">
                    <div class="snapshot-header">
                        <div class="snapshot-title">${snapshot.testName}</div>
                        <div class="snapshot-meta">
                            <span class="badge badge-${snapshot.platform.toLowerCase()}">${snapshot.platform}</span>
                            <span class="badge badge-${snapshot.scheme.toLowerCase()}">${snapshot.scheme}</span>
                            <span>${snapshot.device}</span>
                        </div>
                    </div>
                    <img src="${snapshot.path}" alt="${snapshot.filename}" class="snapshot-image" onclick="openModal('${snapshot.path}')">
                </div>
            `).join('');
        }
        
        function setupFilters() {
            const filterButtons = document.querySelectorAll('.filter-btn');
            filterButtons.forEach(btn => {
                btn.addEventListener('click', () => {
                    // Update active state
                    const group = btn.closest('.filter-group');
                    group.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    
                    // Apply filters
                    applyFilters();
                });
            });
        }
        
        function applyFilters() {
            const platformFilter = document.querySelector('[data-filter="platform"].active')?.dataset.value || 'all';
            const schemeFilter = document.querySelector('[data-filter="scheme"].active')?.dataset.value || 'all';
            const deviceFilter = document.querySelector('[data-filter="device"].active')?.dataset.value || 'all';
            
            const filtered = snapshots.filter(snapshot => {
                return (platformFilter === 'all' || snapshot.platform === platformFilter) &&
                       (schemeFilter === 'all' || snapshot.scheme === schemeFilter) &&
                       (deviceFilter === 'all' || snapshot.device === deviceFilter);
            });
            
            renderGallery(filtered);
        }
        
        function openModal(imagePath) {
            const modal = document.getElementById('modal');
            const modalImage = document.getElementById('modalImage');
            modalImage.src = imagePath;
            modal.classList.add('active');
        }
        
        function closeModal() {
            const modal = document.getElementById('modal');
            modal.classList.remove('active');
        }
        
        // Close modal on outside click
        document.getElementById('modal').addEventListener('click', (e) => {
            if (e.target.id === 'modal') {
                closeModal();
            }
        });
        
        // Initialize on load
        initDashboard();
    </script>
</body>
</html>
EOF

echo "✅ Dashboard generated at: $DASHBOARD_HTML"
echo "📊 Found $SNAPSHOT_COUNT snapshots"
echo "🌐 Open $DASHBOARD_HTML in your browser to view the dashboard"
