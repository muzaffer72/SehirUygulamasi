<?php
// Kullanıcılar Sayfası

// İşlemleri yönet
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_user'])) {
    // Kullanıcı güncelleme işlemi (Mock)
    $success_message = 'Kullanıcı başarıyla güncellendi.';
}

if (isset($_GET['op']) && $_GET['op'] == 'ban' && isset($_GET['id'])) {
    // Kullanıcı engelleme işlemi (Mock)
    $success_message = 'Kullanıcı başarıyla engellendi.';
}

if (isset($_GET['op']) && $_GET['op'] == 'unban' && isset($_GET['id'])) {
    // Kullanıcı engelini kaldırma işlemi (Mock)
    $success_message = 'Kullanıcı engeli başarıyla kaldırıldı.';
}

// Mock kullanıcı verileri
$mockUsers = [
    [
        'id' => 1,
        'username' => 'ahmet_yilmaz',
        'email' => 'ahmet@example.com',
        'user_level' => 'master',
        'points' => 2450,
        'status' => 1,
        'created_at' => '2023-10-15 14:30:00'
    ],
    [
        'id' => 2,
        'username' => 'ayse_demir',
        'email' => 'ayse@example.com',
        'user_level' => 'expert',
        'points' => 1750,
        'status' => 1,
        'created_at' => '2023-11-20 09:15:00'
    ],
    [
        'id' => 3,
        'username' => 'mehmet_kaya',
        'email' => 'mehmet@example.com',
        'user_level' => 'active',
        'points' => 850,
        'status' => 0,
        'created_at' => '2023-12-05 16:45:00'
    ],
    [
        'id' => 4,
        'username' => 'zeynep_celik',
        'email' => 'zeynep@example.com',
        'user_level' => 'contributor',
        'points' => 350,
        'status' => 1,
        'created_at' => '2024-01-10 11:20:00'
    ],
    [
        'id' => 5,
        'username' => 'ali_can',
        'email' => 'ali@example.com',
        'user_level' => 'newUser',
        'points' => 50,
        'status' => 1,
        'created_at' => '2024-02-15 13:40:00'
    ]
];

// Kullanıcı Düzenleme Ekranı
if (isset($_GET['op']) && $_GET['op'] == 'edit' && isset($_GET['id'])) {
    $userId = $_GET['id'];
    
    // Kullanıcıyı bul
    $user = null;
    foreach ($mockUsers as $mockUser) {
        if ($mockUser['id'] == $userId) {
            $user = $mockUser;
            break;
        }
    }
    
    if ($user) {
        ?>
        <div class="container mt-4">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">Kullanıcı Düzenle</h5>
                </div>
                <div class="card-body">
                    <form method="post" action="?page=users">
                        <input type="hidden" name="user_id" value="<?php echo $user['id']; ?>">
                        
                        <div class="mb-3">
                            <label for="username" class="form-label">Kullanıcı Adı</label>
                            <input type="text" class="form-control" id="username" name="username" value="<?php echo $user['username']; ?>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="email" class="form-label">E-posta</label>
                            <input type="email" class="form-control" id="email" name="email" value="<?php echo $user['email']; ?>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="user_level" class="form-label">Kullanıcı Seviyesi</label>
                            <select class="form-select" id="user_level" name="user_level" required>
                                <option value="newUser" <?php echo ($user['user_level'] == 'newUser') ? 'selected' : ''; ?>>Yeni Kullanıcı</option>
                                <option value="contributor" <?php echo ($user['user_level'] == 'contributor') ? 'selected' : ''; ?>>Katkıda Bulunan</option>
                                <option value="active" <?php echo ($user['user_level'] == 'active') ? 'selected' : ''; ?>>Aktif Kullanıcı</option>
                                <option value="expert" <?php echo ($user['user_level'] == 'expert') ? 'selected' : ''; ?>>Uzman</option>
                                <option value="master" <?php echo ($user['user_level'] == 'master') ? 'selected' : ''; ?>>Usta</option>
                            </select>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="status" name="status" <?php echo ($user['status'] == 1) ? 'checked' : ''; ?>>
                            <label class="form-check-label" for="status">Aktif</label>
                        </div>
                        
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <a href="?page=users" class="btn btn-secondary me-md-2">İptal</a>
                            <button type="submit" name="update_user" class="btn btn-primary">Güncelle</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <?php
    } else {
        echo '<div class="alert alert-danger">Kullanıcı bulunamadı.</div>';
    }
} else {
    // Kullanıcılar Listesi
    ?>
    <div class="container-fluid mt-4">
        <?php if (isset($success_message)): ?>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <?php echo $success_message; ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <?php endif; ?>
        
        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                <h6 class="m-0 font-weight-bold text-primary">Kullanıcılar</h6>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Kullanıcı Adı</th>
                                <th>E-posta</th>
                                <th>Seviye</th>
                                <th>Puan</th>
                                <th>Durum</th>
                                <th>Kayıt Tarihi</th>
                                <th>İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($mockUsers as $user): ?>
                                <tr>
                                    <td><?php echo $user['id']; ?></td>
                                    <td><?php echo $user['username']; ?></td>
                                    <td><?php echo $user['email']; ?></td>
                                    <td><?php echo formatUserLevel($user['user_level']); ?></td>
                                    <td><?php echo $user['points']; ?></td>
                                    <td>
                                        <?php if ($user['status'] == 1): ?>
                                            <span class="badge bg-success">Aktif</span>
                                        <?php else: ?>
                                            <span class="badge bg-danger">Engelli</span>
                                        <?php endif; ?>
                                    </td>
                                    <td><?php echo date('d.m.Y H:i', strtotime($user['created_at'])); ?></td>
                                    <td>
                                        <a href="?page=users&op=edit&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-primary me-1"><i class="bi bi-pencil"></i></a>
                                        <?php if ($user['status'] == 1): ?>
                                            <a href="?page=users&op=ban&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Bu kullanıcıyı engellemek istediğinizden emin misiniz?');"><i class="bi bi-ban"></i></a>
                                        <?php else: ?>
                                            <a href="?page=users&op=unban&id=<?php echo $user['id']; ?>" class="btn btn-sm btn-success"><i class="bi bi-check-circle"></i></a>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <?php
}

// Kullanıcı seviyesi formatla
function formatUserLevel($level) {
    switch ($level) {
        case 'newUser':
            return 'Yeni Kullanıcı';
        case 'contributor':
            return 'Katkıda Bulunan';
        case 'active':
            return 'Aktif Kullanıcı';
        case 'expert':
            return 'Uzman';
        case 'master':
            return 'Usta';
        default:
            return 'Bilinmiyor';
    }
}
?>