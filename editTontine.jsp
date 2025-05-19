<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<input type="hidden" name="id" value="${tontine.id}">

<div class="form-group">
    <label>État :</label>
    <select name="etat" class="form-control">
        <option value="ACTIVE" ${tontine.etat == 'ACTIVE' ? 'selected' : ''}>Actif</option>
        <option value="COMPLETED" ${tontine.etat == 'COMPLETED' ? 'selected' : ''}>Terminé</option>
        <option value="CANCELLED" ${tontine.etat == 'CANCELLED' ? 'selected' : ''}>Annulé</option>
    </select>
</div>