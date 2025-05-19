<div id="confirmModal" class="modal">
    <div class="modal-content confirm-modal">
        <div class="confirm-header">
            <i id="confirmIcon" class="fas fa-question-circle"></i>
            <h3 id="confirmTitle">Confirmation</h3>
        </div>
        
        <div class="confirm-body">
            <p id="confirmMessage">Êtes-vous sûr de vouloir effectuer cette action ?</p>
        </div>
        
        <div class="confirm-footer">
            <input type="hidden" id="actionType">
            <input type="hidden" id="recordId">
            
            <button class="btn btn-secondary" onclick="closeConfirmModal()">Annuler</button>
            <button class="btn btn-danger" onclick="processConfirmAction()">Confirmer</button>
        </div>
    </div>
</div>

<style>
.confirm-modal {
    max-width: 450px;
    text-align: center;
}

.confirm-header {
    padding: 15px;
    border-bottom: 1px solid #eee;
}

.confirm-header i {
    font-size: 3em;
    color: #dc3545;
    margin-bottom: 10px;
}

.confirm-body {
    padding: 20px;
}

.confirm-footer {
    padding: 15px;
    border-top: 1px solid #eee;
    display: flex;
    justify-content: space-between;
}
</style>